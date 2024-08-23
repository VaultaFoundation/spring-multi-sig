#!/bin/env bash

NETWORK=${1:-LOCAL}
CONTRACT_DIR="/local/eosnetworkfoundation/repos/eos-system-contracts/build/contracts"

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

cd $HOME || exit
if [ ! -d eosc-build ]; then
  mkdir eosc-build
  cd eosc-build || exit
  curl -L --output eosc_1.4.0_linux_x86_64.tar.gz https://github.com/eoscanada/eosc/releases/download/v1.4.0/eosc_1.4.0_linux_x86_64.tar.gz
  tar xvzf eosc_1.4.0_linux_x86_64.tar.gz
  mv ./eosc $HOME
  PATH=${PATH}:$HOME
  export PATH
  cd $HOME || exit
fi

if [ ! -s .eosc-vault-${ACCOUNT}.json ]; then
  eosc vault create --vault-file .eosc-vault-${ACCOUNT}.json --import
fi

if [ ! -s ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json ]; then
  echo "ERROR: failed to find ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json EXITING"
  exit
fi
cat ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json | jq 1> /dev/null
if [ $? != 0 ]; then
  echo "ERROR: invalid JSON for PREPARE_SAVANNA_ACTIONS.json EXITING"
  exit
fi
eosc -u $ENDPOINT multisig propose $ACCOUNT spring.upd \
    ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json \
    --request-producers --vault-file .eosc-vault-${ACCOUNT}.json

if [ ! -s ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json ]; then
  echo "ERROR: failed to find ${CONTRACT_DIR}/SWITCH_TO_SVNN.json EXITING"
  exit
fi
cat ${CONTRACT_DIR}/SWITCH_TO_SVNN.json | jq 1> /dev/null
if [ $? != 0 ]; then
  echo "ERROR: invalid JSON for SWITCH_TO_SVNN.json EXITING"
  exit
fi
eosc -u $ENDPOINT multisig propose $ACCOUNT spring.svn \
    ${CONTRACT_DIR}/SWITCH_TO_SVNN.json \
    --request-producers --vault-file .eosc-vault-${ACCOUNT}.json
