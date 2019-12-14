# Generate self-signed CA cert

```shell
openssl req -x509 -new -days 365 -batch -nodes -subj "/CN=ca" -out ca.pem -keyout ca.key
```

# Generate CSR for Nginx certificate

```shell
openssl req -new -batch -nodes -subj "/CN=localhost" -keyout nginx.key -out nginx.csr
```

# Generate Nginx certificate signed by CA

```shell
openssl x509 -req -days 365 -in nginx.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out nginx.pem
```