#!/bin/bash

# Function to prompt the user for input
prompt_user() {
    read -p "$1: " input
    echo "$input"
}
prompt_user_default() {
    read -p "$1 [$2]: " input
    echo "${input:-$2}"
}
# Check if OpenSSL is available
if ! command -v openssl &> /dev/null; then
    echo "Error: OpenSSL not found. Please install OpenSSL before running this script."
    exit 1
fi

# Step 1: Generate CA key
echo "Generating CA key..."
openssl genrsa -out development-ca.key 4096

# Step 2: Generate CA certificate
echo "Generating CA certificate key..."
openssl req -x509 -new -nodes -key development-ca.key -sha256 -days 365 -out development-ca.crt

# Step 4: Generate server key
openssl genrsa -out development.key 4096

# Step 5: Create config.cnf
echo "[ req ]
prompt             = no
default_bits       = 4096
distinguished_name = req_distinguished_name
req_extensions     = req_ext" > config.cnf

# Prompt user for information
countryName=$(prompt_user "Enter the development device country name (2 letter code)" )
localityName=$(prompt_user "Enter the development device locality name (State/Province)" )
organizationName=$(prompt_user "Enter the development device organization name (Company)" )
commonName=$(prompt_user "Enter the development device common name (host name)")

echo "[ req_distinguished_name ]
countryName                = $countryName
localityName               = $localityName
organizationName           = $organizationName
commonName                 = $commonName
[ req_ext ]
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]" >> config.cnf

dns1=$(prompt_user "Enter a dns name (1/3)")
if [ -n "$dns1" ]; then
    echo "DNS.1 = $dns1" >> config.cnf
    dns2=$(prompt_user "Enter a dns name (2/3)")
    if [ -n "$dns2" ]; then
        echo "DNS.2 = $dns2" >> config.cnf
        dns3=$(prompt_user "Enter a dns name (3/3)")
        if [ -n "$dns3" ]; then
            echo "DNS.3 = $dns3" >> config.cnf
        fi
    fi
fi

ip1=$(prompt_user "Enter an IP address (1/3)")
if [ -n "$ip1" ]; then
    echo "IP.1 = $ip1" >> config.cnf
    ip2=$(prompt_user "Enter an IP address (2/3)")
    if [ -n "$ip2" ]; then
        echo "IP.2 = $ip2" >> config.cnf
        ip3=$(prompt_user "Enter an IP address (3/3)")
        if [ -n "$ip3" ]; then
            echo "IP.3 = $ip3" >> config.cnf
        fi
    fi
fi

# Step 6: Generate server certificate request
openssl req -new -key development.key -config config.cnf -out development.csr

# Step 7: Verify the CSR
openssl req -in development.csr -noout -text

# Step 8: Issue the certificate
openssl x509 -req -in development.csr -CA development-ca.crt -CAkey development-ca.key -CAcreateserial -out development.crt -days 365 -sha256 -extfile config.cnf -extensions req_ext

# Step 9: Verify the Certificate
openssl x509 -in development.crt -noout -text

echo "Certificate Authority and Server Certificate generation completed successfully."
