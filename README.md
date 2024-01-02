# Certificator
Repository For Generating Certificates

## How to use
Only one script currently: `createAuthorityAndCertificate.sh`

Haven't tested it but created repository after manually working the steps in the README.md of the createAuthorityAndCertificate folder.

It should generate a certificate authority and a certificate. You have to provide at least one DNS and one IP address. Common Name doesn't count.

You will need to install the certificate authority on your devices after generating for the web certificates to be valid.