#!/bin/env bash

cat ~/eosio-wallet/eos-mainnet1.pw| cleos wallet unlock -n eos-mainnet1
ENDPOINT=https://eos.api.eosnation.io
ENDPOINT=http://127.0.0.1:8888
ACCOUNT=proposer.enf
SIG=${1:-spr1.feature}
# spr2.contrac
# spr3.switcht
cleos -u $ENDPOINT multisig exec $ACCOUNT $SIG -p $ACCOUNT

cat ~/eosio-wallet/eos-mainnet1.pw| cleos wallet unlock -n eos-mainnet1
ENDPOINT=https://eos.api.eosnation.io
ACCOUNT=enf.proposer
SIG=spr3.switcht
# spr2.contrac
# spr3.switcht
cleos -u $ENDPOINT multisig exec $ACCOUNT $SIG -p $ACCOUNT

cleos -u $ENDPOINT push action eosio switchtosvnn '{}' -s -d \
     -p eosio@active --json-file /tmp/switchtosvnn.json --expiration 8640000
eosc -u $ENDPOINT multisig propose $ACCOUNT spr3.switcht \
    /tmp/switchtosvnn.json --request-producers --vault-file $HOME/eosio-wallet/.eosc-vault-${ACCOUNT}.json
