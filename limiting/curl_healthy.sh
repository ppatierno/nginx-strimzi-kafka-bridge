#!/usr/bin/env bash

for i in {1..5};
do
    curl http://localhost:80/healthy;
done