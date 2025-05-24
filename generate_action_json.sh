#!/usr/bin/env bash

NETWORK=${1:-LOCAL}
TIME=${2:-"2026-01-01 00:00:00"}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIONS_DIR="${SCRIPT_DIR}/actions"
[ ! -d $ACTIONS_DIR ] && mkdir -p $ACTIONS_DIR
CONTRACT_DIR=/local/eosnetworkfoundation/repos/vaulta-system-contract/build/contracts
TIME_LOCK="NO"

TIME_ACT="eosio.time"
ENDPOINT=http://127.0.0.1:8888

if [ $NETWORK == "JUNGLE" ]; then
  TIME_ACT="time.eosn"
  ENDPOINT=https://jungle4.cryptolions.io:443 
fi

if [ $NETWORK == "KYLIN" ]; then
  TIME_ACT="time.eosn"
  ENDPOINT=https://api.kylin.alohaeos.com
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
  TIME_ACT="time.eosn"
fi


## CREATE JSON TRANSACTIONS FOR FEATURE ACTIVATIONS
# restrict update to a specific time , can not execute before this time
TIME=$(date -u -d "${TIME}" +"%Y-%m-%dT%H:%M:%S")
# generate this even if we don't use it 
cleos -u $ENDPOINT push action $TIME_ACT checktime "[\"${TIME}\"]" -p eosio@active -s -d --json-file ${ACTIONS_DIR}/TIME_LOCK.JSON --expiration 8640000

# create core vaulta account
VAULTA_KEY=EOS77aqrnWUFvjCNxonxGd9vF3LtWCN54dU2NDCa8F2bgP8Ca4xcp
cleos -u $ENDPOINT system newaccount vaulta core.vaulta ${VAULTA_KEY} ${VAULTA_KEY} --stake-net "10.0 EOS" --stake-cpu "10.0 EOS" --buy-ram-kbytes 1000 -pvaulta@active -s -d --json-file ${ACTIONS_DIR}/VAULTA_ACCT.JSON --expiration 8640000

# set code priviledges  
cleos -u $ENDPOINT set account permission core.vaulta active --add-code -pcore.vaulta@active -s -d --json-file ${ACTIONS_DIR}/VAULTA_ADD_CODE.JSON --expiration 8640000

# EOSIO permission action 
cleos -u $ENDPOINT push action eosio setpriv '["core.vaulta", 1]' -p eosio@active -s -d --json-file ${ACTIONS_DIR}/VAULTA_PRIV.JSON --expiration 8640000

# SET NEW ABI and SET NEW CODE
# This is all you need if you are only posting a new contact
cleos -u $ENDPOINT set contract core.vaulta ${CONTRACT_DIR} system.wasm system.abi -p core.vaulta@active -s -d --expiration 8640000 --json-file ${ACTIONS_DIR}/SET_VAULTA_CONTRACT.JSON


cleos -u $ENDPOINT push action core.vaulta init '["2100000000.0000 A"]' -p core.vaulta@active



