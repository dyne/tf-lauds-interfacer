#!/bin/bash
HOST=$1
TIMEOUT=120
INTERVAL=5

echo Waiting for host "$HOST" to respond to ping...
END_TIME=$((SECONDS + TIMEOUT))
while [[ $SECONDS -lt $END_TIME ]]; do
  if ping -c 1 -W 1 "$HOST" &>/dev/null; then
    sleep 1
    echo Host "$HOST" is reachable!
    sleep $INTERVAL
    exit 0
  fi
  echo Host "$HOST" is not reachable, waiting "$INTERVAL"s before retrying...
  sleep $INTERVAL
done

echo Timed out waiting for host "$HOST" to respond to ping.
exit 1
