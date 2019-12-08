# Nginx with Strimzi Kafka Bridge

Start Nginx.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v ~/github/nginx-strimzi-kafka-bridge/nginx.conf:/etc/nginx/nginx.conf nginx
```

## Basic Authentication

Using `htpasswd` creates a password file and related users.
First time create the file from scratch using `-c` flag and type the password.

```shell
htpasswd -c .htpasswd user1
```

Create a second user omitting `-c` flag.

```shell
htpasswd .htpasswd user2
```

> The provided `.htpasswd` example file contains `user1` and `user2` with related passwords `password1` and `password2`

Start Nginx.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v ~/github/nginx-strimzi-kafka-bridge/nginx_basic_auth.conf:/etc/nginx/nginx.conf -v ~/github/nginx-strimzi-kafka-bridge/.htpasswd:/etc/nginx/htpasswd/.htpasswd nginx
```
