#!/bin/env bash

NETWORK=${1:-LOCAL}
ENDPOINT=http://127.0.0.1:8888
ACCOUNT=enf.proposer
SIG="enfsys.blk"

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
fi

if [ ! -f $HOME/eosio-wallet/.network-wallet.wallet ]; then
  cleos wallet create -n network-wallet --file $HOME/eosio-wallet/network-wallet.pw
  cleos wallet import -n network-wallet
fi
cat $HOME/eosio-wallet/.network-wallet.pw | cleos wallet unlock -n network-wallet

cleos --url $ENDPOINT multisig cancel $ACCOUNT $SIG $ACCOUNT