# Docker Compose of day to day Dev related activity

----
## Includes 
`1. MongoDb`

_Copy the **env.mongodb.sample** file to _env.mongodb_ & set your own **credentials**_ 

```cp .env.mongodb.sample .env.mongodb``` 

###### Configurations
    a.MONGO_VERSION
    a.MONGO_VOLUME_NAME
    a.DOCKER_NETWORK
    a.ENVIRONMENT VARIABLES = .env.mongodb 
----
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

`3. ElasticSearch`

`4. PostgresQl`

`5. Redis`

`6. Kafka`

`7. RabbitMQ`