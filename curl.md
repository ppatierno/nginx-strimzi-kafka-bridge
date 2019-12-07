# Producer

```shell
curl -X POST \
  http://localhost:80/topics/test \
  -H 'Content-Type: application/vnd.kafka.json.v2+json' \
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

Create consumer

```shell
curl -X POST \
  http://localhost:80/consumers/my-group-1 \
  -H 'Content-Type: application/vnd.kafka.v2+json' \
  -d '{
	"name": "some-consumer",
	"auto.offset.reset": "earliest",
	"format": "json",
	"enable.auto.commit": false,
	"fetch.min.bytes": 512,
	"consumer.request.timeout.ms": 30000
}'
```

Subscribe topic

```shell
curl -X POST \
  http://localhost:80/consumers/my-group-1/instances/some-consumer/subscription \
  -H 'Content-Type: application/vnd.kafka.v2+json' \
  -d '{ "topics" : ["test"] }'
```

Getting records

```shell
curl -X GET \
  http://localhost:80/consumers/my-group-1/instances/some-consumer/records \
  -H 'Accept: application/vnd.kafka.json.v2+json'
```

Delete consumer

```shell
curl -X DELETE \
  http://localhost:80/consumers/my-group-1/instances/some-consumer
```