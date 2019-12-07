# Nginx with Strimzi Kafka Bridge

```shell
docker run -it --rm --net=host --name nginx-strimzi-kafka-bridge -p 80:80 -v ~/github/nginx-strimzi-kafka-bridge/nginx.conf:/etc/nginx/conf.d/default.conf nginx
```

