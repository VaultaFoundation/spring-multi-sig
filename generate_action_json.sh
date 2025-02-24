#!/usr/bin/env bash

NETWORK=${1:-LOCAL}
TIME=${2:-"2025-03-05 00:00:00"}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIONS_DIR="${SCRIPT_DIR}/actions"
[ ! -d $ACTIONS_DIR ] && mkdir -p $ACTIONS_DIR
EOS_CONTRACT_DIR=/local/eosnetworkfoundation/repos/eos-system-contracts/build-3.7.0/contracts

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
TIME=$(date -u -d "${TIME}" +"%Y-%m-%dT%H:%M:%S")
cleos -u $ENDPOINT push action $TIME_ACT checktime "[\"${TIME}\"]" -p eosio@active -s -d --json-file ${ACTIONS_DIR}/TIME.JSON --expiration 8640000

# SET NEW ABI for v3.6.1 patch release 
cleos -u $ENDPOINT set contract eosio ${EOS_CONTRACT_DIR}/eosio.system eosio.system.wasm eosio.system.abi -s -d \
     -p eosio@active --expiration 8640000 --json-file ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.7.0.JSON
     
jq 'del(.actions[0])' ${ACTIONS_DIR}/TIME.JSON | grep -v '"actions":' | head -n -1 > ${ACTIONS_DIR}/BASE.JSON
jq .actions[0] ${ACTIONS_DIR}/TIME.JSON > ${ACTIONS_DIR}/ACT1.JSON       
jq .actions[0] ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.7.0.JSON > ${ACTIONS_DIR}/ACT2.JSON
jq .actions[1] ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.7.0.JSON > ${ACTIONS_DIR}/ACT3.JSON
cat ${ACTIONS_DIR}/BASE.JSON > ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
echo ',' >> ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
echo '  "actions": [' >> ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
cat  ${ACTIONS_DIR}/ACT1.JSON >> ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
printf ',' >> ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
cat  ${ACTIONS_DIR}/ACT2.JSON >> ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
printf ',' >> ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
cat  ${ACTIONS_DIR}/ACT3.JSON >> ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
echo '  ]' >> ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
echo '}' >> ${ACTIONS_DIR}/TIME_CHECK_EOSIO_SYSTEM_v3.7.0.JSON
