#!/bin/bash
docker inspect --format '{{.NetworkSettings.IPAddress}}' $1
