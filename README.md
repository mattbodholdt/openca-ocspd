# openca-ocspd

OpenCA OCSPD Container - OCSPD can handle both POST and GET requests

Relies on the contents of repos openca/libpki and openca/openca-ocspd

**Requires that you provide four files in various locations in the container.***
***Note: This is a breaking change from previous iterations where a volume could be mounted to /data/ocspd in the container. The original version of this image is still available using the tag mattbodholdt/openca-ocspd:v1 - (4/2019)***

  1. ca.crt - CA Chain - /usr/local/ocspd/etc/ocspd/certs/ca.crt
  2. ocspd.crt - OCSP Signing Cert - /usr/local/ocspd/etc/ocspd/certs/ocspd.crt
  3. ocspd.key - Key for OCSP Signing Cert - /usr/local/ocspd/etc/ocspd/private/ocspd.key
  4. crl.crl - Intermediate CA CRL - /usr/local/ocspd/etc/ocspd/crls/crl.crl

This can be accomplished in various ways, depending on the platform... Here's some ideas:
---
***Docker Volumes***
Mounting volumes to the container as demonstrated in the following example using standalone Docker:
```bash
docker run -dt --name ocspd_container -p 2560:2560 -v /var/containerdata/ocspd_ecdsa/ca.crt:/usr/local/ocspd/etc/ocspd/certs/ca.crt -v /var/containerdata/ocspd_ecdsa/ocspd.crt:/usr/local/ocspd/etc/ocspd/certs/ocspd.crt -v /var/containerdata/ocspd_ecdsa/ocspd.key:/usr/local/ocspd/etc/ocspd/private/ocspd.key -v /var/containerdata/ocspd_ecdsa/crl.crl:/usr/local/ocspd/etc/ocspd/crls/crl.crl mattbodholdt/openca-ocspd:v2
```
To get to bash in the container:
```bash
docker exec -it ocspd_container /bin/bash
```
---
***Kubernetes Secrets***
Another option is to use Kubernetes, save these items as secrets, and mount those secrets.  An example of how to do this on a kubeadm created, bare-metal, cluster with nginx ingress is provided in the kubernetes directory.  In the example manifests, the Kubernetes namespace is "pki".

Create namespace:
```bash
kubectl create namespace pki
```
Create OCSP Signing and CA Secret and CRL Secret from files:
```bash
kubectl create secret generic ocsp-certs --from-file ocspd.crt --from-file=ca.crt --from-file ocspd.key --namespace pki
kubectl create secret generic crl --from-file=crl.crl --namespace pki
```
[More on Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

Modify the host rule in ingress.yml to reflect your desired host name:
```yaml
spec:
  rules:
  - host: your.ocsp.hostname.org
```

Create deployment:
```bash
kubectl apply -f deployment.yml
```
Create service:
```bash
kubectl apply -f service.yml
```
Create ingress resource:
```bash
kubectl apply -f ingress.yml
```
List Pods:
```bash
kubectl get pods -n pki
```
Show Deployment:
```bash
kubectl get deployment ecdsa-ocspd -n pki -o wide
```
---
***Baked into Private Image***
Another option would be to use the Docker Hub image of this project as a source to build your own image which contains your files and host it on a private Docker registry.  A dockerfile to do that would look something like this with the four files in the directory alongside the Dockerfile:

```bash
FROM mattbodholdt/openca-ocspd:v2

COPY crl.crl /usr/local/ocspd/etc/ocspd/crls/crl.crl
COPY ca.crt /usr/local/ocspd/etc/ocspd/certs/ca.crt
COPY ocspd.crt /usr/local/ocspd/etc/ocspd/certs/ocspd.crt
COPY ocspd.key /usr/local/ocspd/etc/ocspd/private/ocspd.key

ENTRYPOINT [ "/usr/local/ocspd/sbin/ocspd", "-stdout", "-c", "/usr/local/ocspd/etc/ocspd/ocspd.xml" ]
```
If you use this method where all the files are in the image, you could also use the test_ocspd.sh script as part of a build process as demonstrated in gitlab-ci-example.yml.  If you don't bake the files into the image, skip the test step as it will fail.

If you choose to use the test script at any point, you'll want to modify it so you're testing with a cert of your own.

**Testing**
To generate test POST and GET requests:
1. Use openssl to generate the post request and write request out.
```bash
hostname="your.ocsp.hostname.org"
port="80"
openssl ocsp -no_nonce -reqout /root/ca_ecdsa/test/ocsptest.req -CAfile /root/ca_ecdsa/intermediate/certs/ecdsa_ca_chain.pem -issuer /root/ca_ecdsa/intermediate/certs/int.ca.crt.pem -cert /root/ca_ecdsa/intermediate/certs/ocsp_test_cert.pem -url "http://${hostname}:${port}" -header "HOST" "${hostname}" -text
```

2. Get the url-encoding of the base64 encoding of the DER encoding of the OCSPRequest (to form the URI of the GET request), use b64url.py.
```bash
curl https://raw.githubusercontent.com/mattbodholdt/openca-ocspd/master/b64url.py > b64url.py
chmod +x b64url.py
python b64url.py /root/ca_ecdsa/test/ocsptest.req
```
***No GUI:***
3. The output of b64url.py is the URI of the GET request and can be tested with curl and parsed with openssl
```bash
curl --silent -X GET http://your.ocsp.hostname.org:80/MEMwQTA%2FMD0wOzAJBgUrDgMCGgUABBSU91ppgoiy3Huh6hMq%2BUZant%2BVmQQUWW0MZSCgXy8pidQyWYcLAW%2BCHmACAhAB > /tmp/res.ocsp
openssl ocsp -respin /tmp/res.ocsp -text -noverify
```
***GUI***
3. The output of b64url.py is the URI of the GET request and can be tested with a graphical tool like Postman.

Once you've generated a URI, modify the URI in test_ocspd.sh and you can repeat the test by running the script.
