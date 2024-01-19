#!/bin/bash
set -euf -o pipefail
mkdir -p "$(dirname "$0")/../secrets/"
cd ..
if [ -f .env ]; then
  export "$(cat .env | grep KAFKA_ZOOKEEPER_TLS_PASSWORD | xargs)"
  export "$(cat .env | grep NON_JAVA_CLIENT_GENERATE_PEM | xargs)"
else
  echo "Couldn't find env"
  exit
fi

cd "$(dirname "$0")/secrets/" || exit
echo "🔖  Generating some fake certificates and other secrets."
echo "⚠️  Remember to type in \"yes\" for all prompts."
sleep 2

TLD="local"
PASSWORD=$KAFKA_ZOOKEEPER_TLS_PASSWORD
TO_GENERATE_PEM="${NON_JAVA_CLIENT_GENERATE_PEM:-yes}"
VALIDITY_IN_DAYS=3650
CA_WORKING_DIRECTORY="certificate-authority"
TRUSTSTORE_WORKING_DIRECTORY="truststore"
KEYSTORE_WORKING_DIRECTORY="keystore"
PEM_WORKING_DIRECTORY="pem"
KAFKA_CERTS='certs'
KAFKA_CLIENT_PROPERTIES='client.properties'
CA_KEY_FILE="ca-key"
CA_CERT_FILE="ca-cert"
VALIDITY_IN_DAYS=3650

cleanup() {
  for i in $CA_WORKING_DIRECTORY $TRUSTSTORE_WORKING_DIRECTORY $KEYSTORE_WORKING_DIRECTORY $PEM_WORKING_DIRECTORY $KAFKA_CERTS; do
    [[ -d $i ]] && rm -r $i
    mkdir -p $i
  done
}
cleanup

# Generate CA key


openssl req -new -x509 -keyout $CA_WORKING_DIRECTORY/$CA_KEY_FILE \
  -out $CA_WORKING_DIRECTORY/$CA_CERT_FILE -days $VALIDITY_IN_DAYS \
  -subj "/CN=omfdydx.${TLD}/OU=omfdydx/O=DYDX/L=Bengaluru/ST=KAR/C=IN" \
  -newkey rsa:4096 -nodes

for i in kafka client; do
#  control-center metrics schema-registry kafka-tools rest-proxy
  echo ${i}
  # Create keystores
  keytool -genkey -noprompt \
    -alias ${i} \
    -dname "CN=${i}, OU=omfdydx, O=DYDX, L=Bengaluru, ST=KAR, C=IN" \
    -keystore $KEYSTORE_WORKING_DIRECTORY/${i}.keystore.jks \
    -keyalg RSA \
    -storepass $PASSWORD \
    -keypass $PASSWORD

  # Create CSR, sign the key and import back into keystore
  echo
  echo "Now a certificate signing request will be made to the keystore."
  keytool -keystore $KEYSTORE_WORKING_DIRECTORY/$i.keystore.jks -alias $i -certreq -file $KEYSTORE_WORKING_DIRECTORY/$i.csr -storepass $PASSWORD -keypass $PASSWORD

  echo
  echo "Now the private key of the certificate authority (CA) will sign the keystore's certificate."
  openssl x509 -req -CA $CA_WORKING_DIRECTORY/$CA_CERT_FILE -CAkey $CA_WORKING_DIRECTORY/$CA_KEY_FILE -in $KEYSTORE_WORKING_DIRECTORY/$i.csr -out $KEYSTORE_WORKING_DIRECTORY/$i-ca-signed.crt -days $VALIDITY_IN_DAYS -CAcreateserial

  echo
  echo "Now the CA will be imported into the keystore."
  keytool -keystore $KEYSTORE_WORKING_DIRECTORY/$i.keystore.jks -alias CARoot -import -file $CA_WORKING_DIRECTORY/$CA_CERT_FILE -storepass $PASSWORD -keypass $PASSWORD -noprompt

  echo
  echo "Now the keystore's signed certificate will be imported back into the keystore."
  keytool -keystore $KEYSTORE_WORKING_DIRECTORY/$i.keystore.jks -alias $i -import -file $KEYSTORE_WORKING_DIRECTORY/$i-ca-signed.crt -storepass $PASSWORD -keypass $PASSWORD

  # Create truststore and import the CA cert.
  echo
  echo "Now the trust store will be generated from the certificate."
  keytool -keystore $TRUSTSTORE_WORKING_DIRECTORY/$i.truststore.jks -alias CARoot -import -file $CA_WORKING_DIRECTORY/$CA_CERT_FILE -storepass $PASSWORD -keypass $PASSWORD -noprompt

  rm -f $KEYSTORE_WORKING_DIRECTORY/$i-ca-signed.crt
  rm -f $KEYSTORE_WORKING_DIRECTORY/$i.csr
  cp $TRUSTSTORE_WORKING_DIRECTORY/$i.truststore.jks $KAFKA_CERTS/
  cp $KEYSTORE_WORKING_DIRECTORY/$i.keystore.jks $KAFKA_CERTS/

done

echo $PASSWORD >sslkey.creds
echo $PASSWORD >keystore.creds
echo $PASSWORD >truststore.creds

rm -f "$KEYSTORE_WORKING_DIRECTORY/*.csr"

if [ $TO_GENERATE_PEM == "yes" ]; then
  echo
  echo "The following files for SSL configuration will be created for a non-java client"
  echo "  $PEM_WORKING_DIRECTORY/ca-root.pem: CA file to use in certificate veriication (ssl_cafile)"
  echo "  $PEM_WORKING_DIRECTORY/client-certificate.pem: File that contains client certificate, as well as"
  echo "                any ca certificates needed to establish the certificate's authenticity (ssl_certfile)"
  echo "  $PEM_WORKING_DIRECTORY/client-private-key.pem: File that contains client private key (ssl_keyfile)"
  rm -rf $PEM_WORKING_DIRECTORY && mkdir $PEM_WORKING_DIRECTORY

  keytool -exportcert -alias CARoot -keystore $KEYSTORE_WORKING_DIRECTORY/kafka.keystore.jks \
    -rfc -file $PEM_WORKING_DIRECTORY/ca-root.pem -storepass $PASSWORD

  keytool -exportcert -alias kafka -keystore $KEYSTORE_WORKING_DIRECTORY/kafka.keystore.jks \
    -rfc -file $PEM_WORKING_DIRECTORY/client-certificate.pem -storepass $PASSWORD

  keytool -importkeystore -srcalias kafka -srckeystore $KEYSTORE_WORKING_DIRECTORY/kafka.keystore.jks \
    -destkeystore cert_and_key.p12 -deststoretype PKCS12 -srcstorepass $PASSWORD -deststorepass $PASSWORD
  openssl pkcs12 -in cert_and_key.p12 -nocerts -nodes -password pass:$PASSWORD \
    | awk '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/' > $PEM_WORKING_DIRECTORY/client-private-key.pem
  rm -f cert_and_key.p12
fi

echo "✅  All done."
echo
echo
sed -i -e "s|password=\S*$|password=${PASSWORD}|g" $KAFKA_CLIENT_PROPERTIES
echo
echo
echo "✅  Client Properties File Updated."
