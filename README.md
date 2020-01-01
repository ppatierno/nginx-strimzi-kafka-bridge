# Nginx with Strimzi Kafka Bridge

This repository provides some examples for using [Nginx](https://www.nginx.com/) reverse proxy in front of the [Strimzi](https://strimzi.io/) [HTTP Kafka Bridge](https://github.com/strimzi/strimzi-kafka-bridge).

## Basic Configuration

Start Nginx mounting a volume for using the provided `nginx.conf` file as the default one.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v $PWD/basic/nginx.conf:/etc/nginx/nginx.conf nginx
```

## Logging

Nginx writes information about encountered issues of different severity levels to the `error.log` file.
Nginx writes information about client requests to the `access.log` file right after the request is processed.

By default, the Nginx Docker image is configured to send Nginx access log and error log to the Docker log collector.
This is done by linking them to `stdout` and `stderr`.
It means that the `access.log` and `error.log` in the `/var/log/nginx` folder are simlinks to `/dev/stdout` and `/dev/stderr`.

```shell
root@new-host:/# ls -al /var/log/nginx/
total 8
drwxr-xr-x 1 root root 4096 Nov 20 01:15 .
drwxr-xr-x 1 root root 4096 Nov 20 01:15 ..
lrwxrwxrwx 1 root root   11 Nov 20 01:15 access.log -> /dev/stdout
lrwxrwxrwx 1 root root   11 Nov 20 01:15 error.log -> /dev/stderr
```

You can customize the logging using all the provided Nginx variables.
For example, logging any request header using `$http_<header>` and response header via `$sent_http_<header>`.

Start Nginx mounting a volume for using the provided `nginx_logging.conf` file as the default one.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v $PWD/logging/nginx_logging.conf:/etc/nginx/nginx.conf nginx
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

## API Key

You can generate API keys using following command:

```shell
openssl rand -base64 18
```

Then you can map each API key with a corresponding user.
The `api_keys.conf` provides an example of such a mapping.

Start Nginx mounting a volume for using the provided `nginx_apikey_auth.conf` file as the default one and the `api_keys.conf` file containing the API keys users mapping.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v $PWD/authentication/nginx_apikey_auth.conf:/etc/nginx/nginx.conf -v $PWD/authentication/api_keys.conf:/etc/nginx/api_keys.conf nginx
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

## Routing

If there are multiple instances of the Strimzi Kafka bridge, it is possible to identifiy each of them with a name like `bridgeX` (with `X` from 1 to the number of instances, i.e. bridge1, bridge2, ...).

### URI based routing

Each bridge endpoint is accessible through the Nginx reverse proxy prefixing the endpoint itself with `/bridgeX` (i.e. for the producer endpoint `/topics/test` on bridge1, it becomes `/bridge1/topics/test`); the Nginx reverse proxy will be in charge of routing the request to the related bridge.

Start Nginx mounting a volume for using the provided `nginx_routing.conf` file as the default one.

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v $PWD/routing/nginx_routing.conf:/etc/nginx/nginx.conf nginx
```

> The provided Nginx configuration relies on two bridges running locally and listening on port 8080 and 8081 respectively.

## Kubernetes deployment

An `nginx.yaml` file is provided for deploying the Nginx reverse proxy on Kubernetes in front of one or more instances of the Strimzi Kafka bridge.
It provides a `Deployment` and a related `Service`.
The Nginx configuration file is mounted as a `ConfigMap` volume named `nginx-config` that could be created from one of the examples.
Before doing that, the `upstream` section should be modified pointing to the correct Strimzi Kafka bridge service deployed in the same Kubernetes cluster; after that, the `ConfigMap` can be created running the following command (i.e. using the basic configuration).

```shell
kubectl create configmap nginx-config --from-file=nginx.conf=basic/nginx.conf
```

Finally, deploy Nginx on Kubernetes by running.

```shell
kubectl apply -f kubernetes/nginx.yaml
```

> if you are deploying on OpenShift (3.x) you could get a "permission denied" in Nginx during its starting process. You can get more information about how to fix it [here](https://access.redhat.com/solutions/3419001).

### Kubernetes Ingress

This repository also provides a Kubernetes Ingress definition for exposing the Nginx reverse proxy.

```shell
kubectl apply -f kubernetes/nginx-ingress.yaml
```

> If you are running Kubernetes using `minikube`, remember to enable the Ingress controller by running `minikube addons enable ingress`. If you are connecting from your laptop to the `minikube` instance, update the `/etc/hosts` in order to reach the host specified in the Ingress declaration mapping it to the Minikube IP address.

### OpenShift Route

This repository also provides a OpenShift Route definition for exposing the Nginx reverse proxy.

```shell
oc apply -f kubernetes/nginx-route.yaml
```

> If you are running OpenShift using `minishift`, the provided route will have an assigned URL using [nip.io](https://nip.io/) so it will be something like `http://nginx-route-myproject.192.168.42.23.nip.io/` which will be reachable directly from your laptop without any further change.