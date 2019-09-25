### Interconnect Router Client certs
rm -rf certs
mkdir certs

# Generate CA key
openssl genrsa -out certs/ca-key.pem 2048

# Create a certificate request.
openssl req -new -sha256 -key certs/ca-key.pem -out certs/ca-csr.pem -subj "/C=GB/ST=London/L=London/O=Acme Ltd/CN=Acme Ltd Root"

# Sign and generate a certificate
openssl x509 -req -in certs/ca-csr.pem -signkey certs/ca-key.pem -out certs/ca-cert.pem

# Generate the client key
openssl genrsa -out certs/client-key.pem 2048

# Generate the Certificate signing request
openssl req -new -batch -sha256 -subj "/CN=client" -key certs/client-key.pem -out certs/client-csr.pem

# Sign the cert using our CA
# This will be used by clients connecting to the router
openssl x509 -req -in certs/client-csr.pem -CA certs/ca-cert.pem -CAkey certs/ca-key.pem -out certs/client-cert.pem -CAcreateserial


# Now do the same for server certs
#openssl genrsa -out certs/server-key.pem 2048
#openssl req -new -sha256 -key certs/server-key.pem -out certs/server-csr.pem -subj "/CN=server"
#openssl x509 -req -in certs/server-csr.pem -CA certs/ca-cert.pem -CAkey certs/ca-key.pem -out certs/server-cert.pem -CAcreateserial


# Java keystores - this will be used by the external Java AMQP test client

# Import the root CA cert into client truststore
keytool -storetype jks -keystore certs/client-jks.truststore -storepass password -keypass password -importcert -alias ca -file certs/ca-cert.pem -noprompt

# Generate certs for AMQ brokers and insert into a truststore (for Java client apps)
keytool -genkey -alias broker -keyalg RSA -keystore certs/broker.ks -keypass password -storepass password -dname "CN=broker,L=London" -storetype pkcs12
keytool -export -alias broker -keystore certs/broker.ks -file certs/broker-cert -storepass password -keypass password
keytool -import -alias broker -keystore certs/client-jks.truststore -file certs/broker-cert -storepass password -keypass password -noprompt
