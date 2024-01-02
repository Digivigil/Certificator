# Creating a Certificate Authority and Web Server Certificates

Run the `createAuthorityAndCertificate.sh` script to generate a certificate authority and a certificate.

Most information came from [How to configure development server certificates for iOS 13 and Mac clients](https://jaanus.com/ios-13-certificates/)

## 1. Generate CA key
   `openssl genrsa -out development-ca.key 4096`


## 2. Generate CA certificate
   `openssl req -x509 -new -nodes -key development-ca.key -sha256 -days 365 -out development-ca.crt`


## 4. Generate server key
   `openssl genrsa -out development.key 4096`

## 5. Create config.cnf:
*Example config.cnf*
    
    [ req ]
    prompt             = no
    default_bits       = 4096
    distinguished_name = req_distinguished_name
    req_extensions     = req_ext
    [ req_distinguished_name ]
    countryName                = US
    localityName               = Oregon
    organizationName           = Digivigil
    commonName                 = blakes-macbook-pro
    [ req_ext ]
    extendedKeyUsage = serverAuth
    subjectAltName = @alt_names
    [alt_names]
    DNS.1 = blakes-macbook-pro
    DNS.2 = localhost
    DNS.3 = blakes-macbook-pro.local
    IP.1 = 192.168.1.230
    IP.2 = 127.0.0.1
    IP.3 = 10.0.1.8

# 6. Generate server certificate request
   `openssl req -new -key development.key -config config.cnf -out development.csr`
# 7. Verify the CSR
   `openssl req -in development.csr -noout -text`
# 8. Issue the certificate
   `openssl x509 -req -in development.csr -CA development-ca.crt -CAkey development-ca.key -CAcreateserial -out development.crt -days 365 -sha256 -extfile config.cnf -extensions req_ext`
# 9. Verify the Certificate
   `openssl x509 -in development.crt -noout -text`


# 10. Install the CA certificate on macOS
Install it in your login keychain. Then, open it and specify “Always Trust” for it.

# 11. Install and Trust the CA certificate on iOS
Airdrop and go to VPN and devices settings to install then go to Settings > General > About > Certificate Trust Settings. Under "Enable full trust for root certificates," turn on trust for the certificate.

https://support.apple.com/en-us/102390
