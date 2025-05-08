# Local Dev Stack: Redis, PostgreSQL, Kafka

This repository contains a `docker-compose.yml` setup to run a complete local development stack using:

- Redis
- PostgreSQL
- Kafka stack:
  - Zookeeper
  - Kafka broker
  - Schema Registry
  - Kafka UI

---

## Prerequisites

Make sure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/)

### Usage

1. **Redis**

    ```sh
    docker exec -it redis_server redis-cli
    AUTH ${REDIS_PASSWORD}
    ```
