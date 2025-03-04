#!/bin/env bash

NETWORK=${1:-LOCAL}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIONS_DIR="${SCRIPT_DIR}/actions"
if [ ! -d $ACTIONS_DIR ]; then
  echo "${ACTIONS_DIR} does not exist"
  exit
fi
ACTION=EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
SIG="enfsys.blk"

ENDPOINT=http://127.0.0.1:8888
ACCOUNT=proposer.enf
VAULT="lvault"

if [ $NETWORK == "JUNGLE" ]; then
  ENDPOINT=https://jungle4.cryptolions.io:443
  ACCOUNT=proposer.enf
  VAULT="jvault"
fi

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
  ACCOUNT=spacerang.gm
  VAULT="kvault"
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
  ACCOUNT=proposer.enf
fi

if [ ! -s $HOME/eosio-wallet/.eosc-${VAULT}-${ACCOUNT}.json ]; then
    eosc vault create --vault-file $HOME/eosio-wallet/.eosc-${VAULT}-${ACCOUNT}.json --import
fi

if [ ! -s ${ACTIONS_DIR}/${ACTION} ]; then
    echo "ERROR: failed to find ${ACTIONS_DIR}/${ACTION} EXITING"
    # exit
fi

# Error check on JSON 
cat ${ACTIONS_DIR}/${ACTION} | jq 1> /dev/null
if [ $? != 0 ]; then
    echo "ERROR: invalid JSON for TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON EXITING"
    # exit
fi
eosc -u $ENDPOINT multisig propose $ACCOUNT $SIG \
    ${ACTIONS_DIR}/${ACTION} \
    --request-producers --vault-file $HOME/eosio-wallet/.eosc-${VAULT}-${ACCOUNT}.json

