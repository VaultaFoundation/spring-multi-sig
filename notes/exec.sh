#!/bin/env bash

cat ~/eosio-wallet/eos-mainnet1.pw| cleos wallet unlock -n eos-mainnet1
ENDPOINT=https://eos.api.eosnation.io
ACCOUNT=enf.proposer
SIG=${1:-spr1.feature}
# spr2.contrac
# spr3.switcht
cleos -u $ENDPOINT multisig exec $ACCOUNT $SIG -p $ACCOUNT
