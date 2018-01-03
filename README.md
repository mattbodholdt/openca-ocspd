# openca-ocspd

OpenCA OCSPD Container

Relies on the contents of repos openca/libpki and openca/openca-ocspd.  (Based on the work done in repo bn0ir/docker-ocspd)

Mount a volume to the container (/data/ocspd/) with ca.crt, ocspd.crt, ocspd.key and crl.crl
In the following docker run example, these files are located in /var/containerdata/ocspd on the Docker host.

docker run -dt --name ocspd_container -p 2560:2560 -v /var/containerdata/ocspd:/data/ocspd mattbodholdt\openca-ocspd

OCSPD can handle both POST and GET requests
