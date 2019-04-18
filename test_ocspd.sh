#!/usr/bin/env bash

set -x
### To generate a test GET and POST reqeust
## use openssl to generate the post request and write request out
# openssl ocsp -no_nonce -reqout /root/ca_ecdsa/test/ocsptest.req -CAfile /root/ca_ecdsa/intermediate/certs/ecdsa_ca_chain.pem -issuer /root/ca_ecdsa/intermediate/certs/int.ca.crt.pem -cert /root/ca_ecdsa/intermediate/certs/client_ecdsa_cert.pem -url "http://$hostname:8081" -header "HOST" "$hostname" -text
## To get the url-encoding of the base64 encoding of the DER encoding of the OCSPRequest (the URI in req), use b64url.py..
# curl https://raw.githubusercontent.com/mattbodholdt/openca-ocspd/master/b64url.py > b64url.py
# python b64url.py /root/ca_ecdsa/test/ocsptest.req

hostname="127.0.0.1:2560"
req="http://$hostname/MEMwQTA%2FMD0wOzAJBgUrDgMCGgUABBSU91ppgoiy3Huh6hMq%2BUZant%2BVmQQUWW0MZSCgXy8pidQyWYcLAW%2BCHmACAhAB"
response=$(curl --write-out %{http_code} --silent --output /dev/null $req)

if [ $response = 200 ]; then
  echo "$response Response, testing..."
  curl --silent -X GET $req > /tmp/res.ocsp
  ocspres=$(openssl ocsp -respin /tmp/res.ocsp -text -noverify)
  if [ -z "$(echo "$ocspres" | grep "OCSP Response Status: successful \(0x0\)")" ]; then
    echo "$ocspres"
    rm -rf /tmp/res.ocsp
    echo "Success!"
  else
    echo "$response"
    echo "$ocspres"
    rm -rf /tmp/res.ocsp
    echo "Unsuccessful"
    exit 1
  fi
else
  echo "Failure"
  echo "Response code: $response"
  exit 1
fi
