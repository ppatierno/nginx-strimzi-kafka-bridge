# Introduction

The following `curl` commands describe examples for interacting with the Strimzi Kafka Bridge through the Nginx proxy.

If HTTP Basic Authentication is enabled on the Nginx proxy, export following `BASIC_AUTH` for adding the `Authorization` header in the HTTP requests.
Use the appropriate user and password.
For example:

```shell
export BASIC_AUTH="Authorization: Basic $(echo -n user1:password1 | base64)"
```

If API Key based authentication is enabled on the Nginx proxy, export following `APIKEY_AUTH` for adding the `apikey` header in the HTTP requests.
Use the appropriate apikey.
For example:

```shell
export APIKEY_AUTH="apikey: qYOGjP4HstJ5jwQvWiQLw+5Y"
```

# Producer

Producer records.

```shell
curl -X POST \
  http://localhost:80/topics/test \
  -H 'Content-Type: application/vnd.kafka.json.v2+json' \
  -H "${BASIC_AUTH}" \
  -H "${APIKEY_AUTH}" \
  -d '{
	"records": [
		{
			"key": "key1",
			"value": { "foo": "bar", "aaa": 5 }
		}
	]
}'
```

# Consumer

## Create consumer

```shell
curl -X POST \
  http://localhost:80/consumers/my-group-1 \
  -H 'Content-Type: application/vnd.kafka.v2+json' \
  -H "${BASIC_AUTH}" \
  -H "${APIKEY_AUTH}" \
  -d '{
	"name": "some-consumer",
	"auto.offset.reset": "earliest",
	"format": "json",
	"enable.auto.commit": false,
	"fetch.min.bytes": 512,
	"consumer.request.timeout.ms": 30000
}'
```

## Subscribe topic

```shell
curl -X POST \
  http://localhost:80/consumers/my-group-1/instances/some-consumer/subscription \
  -H 'Content-Type: application/vnd.kafka.v2+json' \
  -H "${BASIC_AUTH}" \
  -H "${APIKEY_AUTH}" \
  -d '{ "topics" : ["test"] }'
```

## Getting records

```shell
curl -X GET \
  http://localhost:80/consumers/my-group-1/instances/some-consumer/records \
  -H 'Accept: application/vnd.kafka.json.v2+json' \
  -H "${BASIC_AUTH}" \
  -H "${APIKEY_AUTH}"
```

## Delete consumer

```shell
curl -X DELETE \
  http://localhost:80/consumers/my-group-1/instances/some-consumer \
  -H "${BASIC_AUTH}" \
  -H "${APIKEY_AUTH}"
```