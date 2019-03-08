#!/bin/bash

PAYLOAD=256k.bin

for i in `seq 1 100`; do
    echo "Request $i"
    curl -X POST --tcp-nodelay --data-binary @${PAYLOAD} -H 'Content-Type: application/raw' http://localhost:8080/post
done
curl http://localhost:8080/stats
