#!/bin/env bash

NETWORK=${1:-LOCAL}
ENDPOINT=http://127.0.0.1:8888
ACCOUNT=spaceranger1

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
  ACCOUNT=spacerang.gm
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
fi

cleos wallet create -n network-wallet --file .network-wallet.pw
cleos wallet import -n network-wallet

cleos --url $ENDPOINT multisig cancel $ACCOUNT spring.svn $ACCOUNT
cleos --url $ENDPOINT multisig cancel $ACCOUNT spring.upd $ACCOUNT
