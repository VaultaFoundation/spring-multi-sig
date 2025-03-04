#!/usr/bin/env bash

NETWORK=${1:-LOCAL}
TIME=${2:-"2025-03-05 00:00:00"}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIONS_DIR="${SCRIPT_DIR}/actions"
[ ! -d $ACTIONS_DIR ] && mkdir -p $ACTIONS_DIR
EOS_CONTRACT_DIR=/local/eosnetworkfoundation/repos/eos-system-contracts/build/contracts
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
cleos -u $ENDPOINT push action $TIME_ACT checktime "[\"${TIME}\"]" -p eosio@active -s -d --json-file ${ACTIONS_DIR}/TIME.JSON --expiration 8640000

# SET NEW ABI  
cleos -u $ENDPOINT set contract eosio ${EOS_CONTRACT_DIR}/eosio.system eosio.system.wasm eosio.system.abi -s -d \
     -p eosio@active --expiration 8640000 --json-file ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0.JSON

# local only action not on proposed network   
#cleos -u $ENDPOINT push action eosio denyhashadd '{"hash":"2c7961964f7136dd433e7438b37fe167e3f8a39bcfa993bff18f18535ce6e5d0"}' -s -d \
#      -p eosio@active --expiration 8640000 --json-file ${ACTIONS_DIR}/ADD_HASH.JSON

jq 'del(.actions[0])' ${ACTIONS_DIR}/TRANSFER.JSON | grep -v '"actions":' | head -n -1 > ${ACTIONS_DIR}/BASE.JSON
jq .actions[0] ${ACTIONS_DIR}/ADD_HASH.JSON > ${ACTIONS_DIR}/ACT3.JSON       
jq .actions[0] ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0.JSON > ${ACTIONS_DIR}/ACT1.JSON
jq .actions[1] ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0.JSON > ${ACTIONS_DIR}/ACT2.JSON
cat ${ACTIONS_DIR}/BASE.JSON > ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
echo ',' >> ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
echo '  "actions": [' >> ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
cat  ${ACTIONS_DIR}/ACT1.JSON >> ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
printf ',' >> ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
cat  ${ACTIONS_DIR}/ACT2.JSON >> ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
printf ',' >> ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
cat  ${ACTIONS_DIR}/ACT3.JSON >> ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
echo '  ]' >> ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON
echo '}' >> ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.8.0_HASH_ADD.JSON

if [ $TIME_LOCK != "NO" ]; then 
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
fi
