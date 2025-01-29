#!/bin/env bash

cat ~/eosio-wallet/eos-mainnet1.pw| cleos wallet unlock -n eos-mainnet1
ENDPOINT=https://eos.api.eosnation.io
ENDPOINT=http://127.0.0.1:8888
ACCOUNT=proposer.enf
SIG=${1:-enfsys.erm}
# spr2.contrac
# spr3.switcht
cleos -u $ENDPOINT multisig exec $ACCOUNT $SIG -p $ACCOUNT