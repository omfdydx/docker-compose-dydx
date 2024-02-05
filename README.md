# Docker Compose Dy-by-Dx !


![alt text](https://i.imgur.com/6mSCz9P.png "KISS")

**KISS** - _Keeping Infra Simple Stupid_  

Create the daily used services / infrastructure for development in a single compose which
are configurable. 
- Regular Used Services for my works
- Fully configurable in terms of 
  - **ENV** variables
  - **Docker Networks**
  - **Docker Volumes**

```
Examples

a. Start all services
  >task all

b. Start only Mongodb
  >task mongodb-up

c. Watch Mongo Logs
  >task mongodb-logs

d. Shutdown all services & clean up
  >task shutdown
....
...
..
.
And so on !!
This way any combination of services can be Started | Stopped | Monitored
as per the Project Dev is working on currently


Note: To leverage simple commands for start/stop/logs install Go and Taskfile 
as per the instructions
https://taskfile.dev/installation/
```  

| Service         | Type                  | Configured | 
|-----------------|-----------------------|------------|
 | *MongoDB*       | `Database`            | **Y**      |
 | *Emqx*          | `MQTT Broker`         | **Y**      |
 | *Elasticsearch* | `Database`            | **Y**      |
 | *Kibana*        | `Analytics Dashboard` | **Y**      |
 | *PostgresQl*    | `Database`            | **Y**      |
 | *Redis*         | `Cache`               | **Y**      |
 | *Kafka*         | `Broker`              | **Y**      |
 | *Simple Kafka*  | `Broker`              | **Y**      | 
 | *RabbitMQ*      | `Broker`              | **N**      |

----
## Includes 
`1. MongoDb`

_Copy the **env.mongodb.sample** file to _env.mongodb_ & set your own **credentials**_ 

```cp .env.mongodb.sample .env.mongodb``` 

###### Configurations
    a.MONGO_VERSION
    b.MONGO_VOLUME_NAME
    c.DOCKER_NETWORK
    d.ENVIRONMENT VARIABLES = .env.mongodb 

```bash
  >task mongodb-up
  >task mongodb-logs
  >task mongodb-down
```

--------
--------

`2. Emqx` 

_Copy the **env.emqx.sample** file to _env.emqx_ & set your own **credentials**_

```cp .env.emqx.sample .env.emqx```
###### Configurations
    a. EMQX_VERSION
    b. EMQX_VOLUME_NAME
    c. EMQX_CONTAINER_NAME
    d. EMQX_TCP_DEFAULT
    e. EMQX_DASHBOARD_DEFAULT
    f. ENVIRONMENT VARIABLES = .env.emqx

```bash
  >task emqx-up
  >task emqx-logs
  >task emqx-down
```
--------
--------
`3. ElasticSearch`

_Copy the **env.elasticsearch.sample** file to _env.elasticsearch_ & set your own **credentials**_

```cp .env.elasticsearch.sample .env.elasticsearch```

```bash
Step 1: >task elasticsearch-setup

**Wait for the configuration to successfully exit 
for passwords & certificates to be set properly**



  >task elasticsearch-up
  >task elasticsearch-logs
  >task elasticsearch-down
  
#  ------------------------------ Check elastic is working --------------------------- 
  docker cp omfdydx-elasticsearch:/usr/share/elasticsearch/config/certs/ca/ca.crt /tmp/.
  curl --cacert /tmp/ca.crt -u elastic:elasticpasswd https://localhost:3200
# -------------------------------------------------------------------------------------

```
###### Configurations
    a. ELASTICSEARCH_VERSION
    b. ELASTICSEARCH_VOLUME_NAME
    c. ELASTICSEARCH_CERTS_VOLUME_NAME
    d. KIBANA_VOLUME_NAME
    e. ELASTICSEARCH_TCP_DEFAULT ....et al
    f. ENVIRONMENT VARIABLES = .env.elasticsearch
--------
--------

`4. Kibana`
```bash
- It is configured via the elasticsearch env. Nothing else to do

  >task kibana-up
  >task kibana-logs
  >task kibana-down

```
--------
--------

`5. Postgresql`

_Copy the **env.postgresql.sample** file to _env.postgresql_ & set your own **credentials**_

```cp .env.postgresql.sample .env.postgresql```
###### Configurations
    a. POSTGRESQL_VERSION
    b. POSTGRESQL_VOLUME_NAME
    c. POSTGRESQL_CONTAINER_NAME
    d. POSTGRESQL_TCP_DEFAULT
    e. POSTGRESQL_TCP
    f. ENVIRONMENT VARIABLES = .env.postgresql

```bash
  >task postgresql-up
  >task postgresql-logs
  >task postgresql-down
```
--------
--------

`6. Redis`

_Copy the **env.redis.sample** file to _env.redis_ & set your own **credentials**_

```cp .env.redis.sample .env.redis```
###### Configurations
    a. REDIS_VERSION
    b. REDIS_VOLUME_NAME
    c. REDIS_CONTAINER_NAME
    d. REDIS_TCP_DEFAULT
    e. REDIS_TCP
    f. ENVIRONMENT VARIABLES = .env.redis

```bash
  >task redis-up
  >task redis-logs
  >task redis-down
```
--------
--------
`7. Kafka`

###### To set up the certificates for secure connections with clients. Kafka setup uses [Kraft]() rather [zookeeper]()

```bash
cd scripts && bash create-certs.sh
# Generates the secrets folder with 
# - certs, 
# - keystore, 
# - truststore, 
# - pem[Connecting to Kafka via non-Java clients] 
# - clients.properties
```

_Copy the **env.kafka.sample** file to _env.kafka_ & set your own **credentials**_

```cp .env.kafka.sample .env.kafka```
###### Configurations
    a. KAFKA_VERSION
    b. KAFKA_ZOOKEEPER_TLS_PASSWORD
    c. NON_JAVA_CLIENT_GENERATE_PEM
    d. KAFKA_CONTAINER_NAME
    e. KAFKA_VOLUME_NAME
    f. ENVIRONMENT VARIABLES = .env.kafka

```bash
  >task kafka-up
  >task kafka-logs
  >task kafka-down
```

```bash
#Checking the consumers can connect via SSL/TLS
# Get into the container 1. producer 2. consumer
docker exec -it omfdydx-kafka bash

# 1. Inside the container **9095** SSL/TLS listener
cd /opt/bitnami/kafka/bin/
./kafka-topics.sh --bootstrap-server kafka:9095 --create --topic inventory \ 
 --partitions 3 --command-config /opt/bitnami/kafka/config/client.properties
 > hello: world, good: bye

# 2. Check the consumer
cd /opt/bitnami/kafka/bin/
./kafka-console-consumer.sh --bootstrap-server kafka:9095 \
--topic inventory --consumer.config /opt/bitnami/kafka/config/client.properties --from-beginning
 
# 3. List the topics
 ./kafka-topics.sh --list --command-config /opt/bitnami/kafka/config/client.properties \
  --bootstrap-server kafka:9095
```

------
------
`8. Simple Kafka - No Auth & Certs - Single Node`

_Copy the **env.safka.sample** file to _env.safka_ & set your own **credentials**_

```cp .env.safka.sample .env.safka```
###### Configurations
    a. SAFKA_VOLUME_NAME
    b. SAFKA_CONTAINER_NAME
    c. SAFKA_PORT
    d. SAFKA_PORT_DEFAULT
    f. ENVIRONMENT VARIABLES = .env.safka

```bash
  >task safka-up
  >task safka-logs
  >task safka-down
```


`8. RabbitMQ`
