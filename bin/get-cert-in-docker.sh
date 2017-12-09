# First, move the old certificate if any 
mkdir -p /app/cert/old &> /dev/null
mv /app/cert/* /app/cert/old &> /dev/null

# Get a certificate
certbot certonly --webroot --webroot-path=/app -d $HOST

# Make a diffie-helman group
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Copy the certificate into the /app dir.  This copies the cert file to the
# host, since /app is a mapped volume
cp /etc/letsencrypt/live/$HOST/* /app/cert
cp /etc/ssl/certs/dhparam.pem /app/cert

# Finally, restart nginx so that it reads in the new certificate
/etc/init.d/nginx restart
