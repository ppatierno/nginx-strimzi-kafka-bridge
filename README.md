# Nginx with Strimzi Kafka Bridge

This repository provides some examples for using [Nginx](https://www.nginx.com/) reverse proxy in front of the [Strimzi](https://strimzi.io/) [HTTP Kafka Bridge](https://github.com/strimzi/strimzi-kafka-bridge).

## Basic Configuration

Start Nginx mounting a volume for using the provided `nginx.conf` file as the default one.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v ~/github/nginx-strimzi-kafka-bridge/nginx.conf:/etc/nginx/nginx.conf nginx
```

## Basic Authentication

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
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v ~/github/nginx-strimzi-kafka-bridge/nginx_basic_auth.conf:/etc/nginx/nginx.conf -v ~/github/nginx-strimzi-kafka-bridge/.htpasswd:/etc/nginx/htpasswd/.htpasswd nginx
```

## Rate Limiting

Start Nginx mounting a volume for using the provided `nginx_rate_limiting` file as the default one.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v ~/github/nginx-strimzi-kafka-bridge/nginx_rate_limiting.conf:/etc/nginx/nginx.conf nginx
```

In this configuration, the proxy limits the incoming requests as maximum 1 request/sec.
If it is exceeded, the proxy return error `503 Service Unavailable`.