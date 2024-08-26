#!/bin/env bash

cat ~/eosio-wallet/finality-test-network-wallet.pw | cleos wallet unlock -n finality-test-network-wallet
ACCOUNT=spaceranger1
SIG=${1:-spr1.feature}
# spr2.contrac
# spr3.switcht
cleos multisig exec $ACCOUNT $SIG -p bpa@active
