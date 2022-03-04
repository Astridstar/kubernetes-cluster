## Demo Application Links
[Flink Demo Application Website](https://flink.apache.org/2020/07/28/flink-sql-demo-building-e2e-streaming-application.html)

[Hue-Fink Demo Website](https://gethue.com/blog/tutorial-query-live-data-stream-with-flink-sql/)

### Flink Demo Details
Deployment order:

- Zookeeper
- Kafka
- Elasticsearch
- Kibana
- datagen
- jobmanager
- taskmanager
- sqlclient

Note for zookeeper and kafka currenly only deployment method works and not statefulset. Need to debug more when time permits.
