#!/bin/bash

# Start core
docker compose up -d --scale ue=0

# Wait for AMF to be ready
while ! docker compose logs amf | grep -q "Ready"; do
  sleep 2
done

# Start logging
docker compose logs -f > trace_$(date +%s).log &
LOGPID=$!

# Start UE
docker compose up -d ue
sleep 2  # Wait for UE to initialize

# Trigger registration
docker compose exec ue curl -X POST http://localhost:5000/trigger-registration

# Wait for completion
while ! docker compose logs ue | grep -q "Registration Complete"; do
  sleep 1
done

# Stop logging
kill $LOGPID
