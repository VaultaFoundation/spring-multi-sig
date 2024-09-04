#!/bin/env bash

CREATOR=eosio
ACCOUNT=spaceranger1
ENDPOINT=http://127.0.0.1:8888

PUB_KEY=$(grep Public ~/eosio-wallet/${ACCOUNT}.keys | cut -d: -f2 | sed 's/\s//')
cleos -u $ENDPOINT system newaccount $CREATOR $ACCOUNT \
  $PUB_KEY $PUB_KEY --stake-net "1000.0 EOS" --stake-cpu "1000.0 EOS" --buy-ram-kbytes 1000

ACCOUNT=enf.signator
PUB_KEY=$(grep Public ~/eosio-wallet/${ACCOUNT}.keys | cut -d: -f2 | sed 's/\s//')
cleos -u $ENDPOINT system newaccount $CREATOR $ACCOUNT \
  $PUB_KEY $PUB_KEY --stake-net "1000.0 EOS" --stake-cpu "1000.0 EOS" --buy-ram-kbytes 1000

ACCOUNT=enf.proposer
PUB_KEY=$(grep Public ~/eosio-wallet/${ACCOUNT}.keys | cut -d: -f2 | sed 's/\s//')
cleos -u $ENDPOINT system newaccount $CREATOR $ACCOUNT \
  $PUB_KEY $PUB_KEY --stake-net "1000.0 EOS" --stake-cpu "1000.0 EOS" --buy-ram-kbytes 1000
