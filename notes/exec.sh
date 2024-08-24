#!/bin/env bash

cat ~/eosio-wallet/finality-test-network-wallet.pw | cleos wallet unlock -n finality-test-network-wallet
ACCOUNT=spaceranger1
SIG=${1:-spring.upd}
cleos multisig exec $ACCOUNT $SIG -p bpa@active
