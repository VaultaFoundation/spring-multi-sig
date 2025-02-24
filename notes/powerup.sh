#!/bin/env bash

cat ~/eosio-wallet/eos-mainnet1.pw | cleos wallet unlock -n eos-mainnet1
USER="proposer.enf"
ENDPOINT=https://eos.api.eosnation.io

cleos -u $ENDPOINT push action eosio powerup "[${USER}, ${USER}, 1, 1000000000, 1000000000, \"1.0000 EOS\"]" -p ${USER}