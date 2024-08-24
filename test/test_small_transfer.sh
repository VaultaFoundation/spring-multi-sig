#!/bin/env bash

#!/bin/env bash

NETWORK=${1:-LOCAL}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIONS_DIR="${SCRIPT_DIR}/actions"
if [ ! -d $ACTIONS_DIR ]; then
  echo "${ACTIONS_DIR} does not exist"
  exit
fi

#PUBLIC_SIG_KEY=EOS81nrWtjvMfDi9E7ddb5nbub2hBWWg6Kih7Y5oTuNPFv5mE72zN

ENDPOINT=http://127.0.0.1:8888
ACCOUNT=spaceranger1

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
  ACCOUNT=spacerang.gm
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
fi

cleos transfer eosio bpa "0.001 EOS" "very small trx" -p eosio@active -s -d --json-file ${ACTIONS_DIR}/verysmalltrans.json --expiration 8640000
eosc -u $ENDPOINT multisig propose $ACCOUNT smalltrxb ${ACTIONS_DIR}/verysmalltrans.json --request-producers --vault-file .eosc-vault-${ACCOUNT}.json
