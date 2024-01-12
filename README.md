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

| Service         | Type                  | Configured  | 
|-----------------|-----------------------|-------------|
 | *MongoDB*       | `Database`            | **Y**       |
 | *Emqx*          | `MQTT Broker`         | **Y**       |
 | *Elasticsearch* | `Database`            | **Y**       |
 | *Kibana*        | `Analytics Dashboard` | **Y**       |
 | *PostgresQl*    | `Database`            | **N**       |
 | *Redis*         | `Cache`               | **N**       |
 | *Kafka*         | `Broker`              | **N**       |
 | *RabbitMQ*      | `Broker`              | **N**       |

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

`5. PostgresQl`

`6. Redis`

`7. Kafka`

`8. RabbitMQ`
