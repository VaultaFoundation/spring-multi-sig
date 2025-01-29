#!/usr/bin/env bash

NETWORK=${1:-LOCAL}
TIME=${2:-"2025-02-08 13:00:00"}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIONS_DIR="${SCRIPT_DIR}/actions"
[ ! -d $ACTIONS_DIR ] && mkdir -p $ACTIONS_DIR
EOS_CONTRACT_DIR=/local/eosnetworkfoundation/repos/eos-system-contracts/build/contracts

ENDPOINT=http://127.0.0.1:8888
JUNGLE=https://jungle4.cryptolions.io:443
TIME_ACT="eosio.time"

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
  TIME_ACT="time.eosn"
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
  TIME_ACT="time.eosn"
fi


## CREATE JSON TRANSACTIONS FOR FEATURE ACTIVATIONS
# restrict update to a specific time , can not execute before this time
#TIME=$(date -u -d "${TIME}" +"%Y-%m-%dT%H:%M:%S")
#cleos -u $ENDPOINT push action $TIME_ACT checktime "[\"${TIME}\"]" -p eosio@active -s -d --json-file ${ACTIONS_DIR}/time.json --expiration 8640000

# SET NEW ABI for v3.6.1 patch release 
cleos -u $ENDPOINT set abi eosio ${EOS_CONTRACT_DIR}/eosio.system/eosio.system.abi -s -d \
     -p eosio@active --expiration 8640000 --json >  ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.6.1.JSON