# Nginx with Strimzi Kafka Bridge

This repository provides some examples for using [Nginx](https://www.nginx.com/) reverse proxy in front of the [Strimzi](https://strimzi.io/) [HTTP Kafka Bridge](https://github.com/strimzi/strimzi-kafka-bridge).

## Logging

Nginx writes information about encountered issues of different severity levels to the `error.log` file which by default it defined as a simlink to `/dev/stderr`.

Nginx writes information about client requests to the `access.log` file right after the request is processed; by default it's defined a simlink to `/dev/stdout`.

You can customize it using all the provided Nginx variables, for example logging any request header using `$http_<header>` and response header via `$sent_http_<header>`.

Start Nginx mounting a volume for using the provided `nginx_logging.conf` file as the default one.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v $PWD/logging/nginx_logging.conf:/etc/nginx/nginx.conf nginx
```

## Basic Configuration

Start Nginx mounting a volume for using the provided `nginx.conf` file as the default one.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v $PWD/basic/nginx.conf:/etc/nginx/nginx.conf nginx
```

## Authentication

### Basic Authentication

Use `htpasswd` to create a password file containing related users.
First time create the file from scratch using `-c` flag and type the password.

```shell
htpasswd -c .htpasswd user1
```

Create a second user omitting `-c` flag.

```shell
htpasswd .htpasswd user2
```

> The provided `.htpasswd` example file contains `user1` and `user2` with related passwords `password1` and `password2`

Start Nginx mounting a volume for using the provided `nginx_basic_auth.conf` file as the default one and the `.htpasswd` file as users and passwords file.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v $PWD/authentication/nginx_basic_auth.conf:/etc/nginx/nginx.conf -v $PWD/authentication/.htpasswd:/etc/nginx/htpasswd/.htpasswd nginx
```

## Limiting

### Rate Limiting

Start Nginx mounting a volume for using the provided `nginx_rate_limiting` file as the default one.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v $PWD/limiting/nginx_rate_limiting.conf:/etc/nginx/nginx.conf nginx
```

In this configuration, the proxy limits the incoming requests as maximum 1 request/sec.
If it is exceeded, the proxy return error `503 Service Unavailable`.

It is possible to have the proxy accepting a `burst` of requests but processing them at fixed rate (defined by the rate limiting).
When the burst is exceeded, the proxy returns an error.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v $PWD/limiting/nginx_rate_limiting_burst.conf:/etc/nginx/nginx.conf nginx
```

## Encryption

Start Nginx mounting a volume for using the provided `nginx_encryption` file as the default one.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 8443:8443 -v $PWD/encryption/nginx_encryption.conf:/etc/nginx/nginx.conf -v $PWD/encryption/nginx.pem:/etc/nginx/certs/nginx.pem -v $PWD/encryption/nginx.key:/etc/nginx/certs/nginx.key nginx
```

> The provided CA certificate has `ca` as CN and the Nginx certificate has `localhost` so that running a test locally like `curl --cacert ca.pem -v https://localhost:8443/healthy` just works with hostname verification as well.