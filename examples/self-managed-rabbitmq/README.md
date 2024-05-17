# Self-Managed RabbitMQ Installation

Some installation environments may need to manage their own
RabbitMQ broker. Not all AWS environments have Amazon MQ yet.

## Prerequisites

You will need the ability to provision a RabbitMQ broker. There
must be a user configured for the application (default is `bigeye`).
The password must be passed through into the application as an AWS
Secrets Manager Secret. You will also need its `amqps` endpoint.

## Configuration

You will configure your main terraform file similar to the "Standard" example.
There is a [rabbit.tf](./rabbit.tf) file in this directory that creates a
very basic Amazon MQ RabbitMQ Broker and password. How you create your
RabbitMQ broker may be different.

