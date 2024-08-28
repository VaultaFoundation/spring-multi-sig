#!/bin/env bash

NETWORK=${1:-LOCAL}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIONS_DIR="${SCRIPT_DIR}/actions"
if [ ! -d $ACTIONS_DIR ]; then
  echo "${ACTIONS_DIR} does not exist"
  exit
fi

ENDPOINT=http://127.0.0.1:8888
ACCOUNT=spaceranger1

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
  ACCOUNT=spacerang.gm
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
  ACCOUNT=enf.proposer
fi

if [ ! -s .eosc-vault-${ACCOUNT}.json ]; then
  eosc vault create --vault-file $HOME/.eosc-vault-${ACCOUNT}.json --import
fi

if [ ! -s ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json ]; then
  echo "ERROR: failed to find ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json EXITING"
  exit
fi
cat ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json | jq 1> /dev/null
if [ $? != 0 ]; then
  echo "ERROR: invalid JSON for PREPARE_SAVANNA_ACTIONS.json EXITING"
  exit
fi
eosc -u $ENDPOINT multisig propose $ACCOUNT spr1.feature \
    ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json \
    --request-producers --vault-file $HOME/.eosc-vault-${ACCOUNT}.json

if [ ! -s ${ACTIONS_DIR}/SETCONTRACT.json ]; then
  echo "ERROR: failed to find ${ACTIONS_DIR}/SETCONTRACT.json EXITING"
  exit
fi
cat ${ACTIONS_DIR}/SETCONTRACT.json | jq 1> /dev/null
if [ $? != 0 ]; then
  echo "ERROR: invalid JSON for SETCONTRACT.json EXITING"
  exit
fi
eosc -u $ENDPOINT multisig propose $ACCOUNT spr2.contrac \
    ${ACTIONS_DIR}/SETCONTRACT.json \
    --request-producers --vault-file $HOME/.eosc-vault-${ACCOUNT}.json

if [ ! -s ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json ]; then
  echo "ERROR: failed to find ${ACTIONS_DIR}/SWITCH_TO_SVNN.json EXITING"
  exit
fi
cat ${ACTIONS_DIR}/SWITCH_TO_SVNN.json | jq 1> /dev/null
if [ $? != 0 ]; then
  echo "ERROR: invalid JSON for SWITCH_TO_SVNN.json EXITING"
  exit
fi
eosc -u $ENDPOINT multisig propose $ACCOUNT spr3.switcht \
    ${ACTIONS_DIR}/SWITCH_TO_SVNN.json \
    --request-producers --vault-file $HOME/.eosc-vault-${ACCOUNT}.json
