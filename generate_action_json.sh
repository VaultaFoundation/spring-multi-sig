#!/usr/bin/env bash

NETWORK=${1:-LOCAL}
TIME=${2:-"2024-09-25 13:00:00"}
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

###############
## FIRST TRX
## spr1.feature
## SYS CONTRACT UPDATE
###############
## CREATE JSON TRANSACTIONS FOR FEATURE ACTIVATIONS
# specific date date -u -d "2030-01-01 00:00:00" +"%Y-%m-%dT%H:%M:%S.000"
TIME=$(date -u -d "${TIME}" +"%Y-%m-%dT%H:%M:%S")
cleos -u $ENDPOINT push action $TIME_ACT checktime "[\"${TIME}\"]" -p eosio@active -s -d --json-file ${ACTIONS_DIR}/time.json --expiration 8640000

# DISABLE_DEFERRED_TRXS_STAGE_1
cleos --url $ENDPOINT push action eosio activate '["fce57d2331667353a0eac6b4209b67b843a7262a848af0a49a6e2fa9f6584eb4"]' -s -d \
    -p eosio@active --json-file ${ACTIONS_DIR}/activate-disable-deferred-1-action.json --expiration 8640000
# DISABLE_DEFERRED_TRXS_STAGE_2
cleos --url $ENDPOINT push action eosio activate '["09e86cb0accf8d81c9e85d34bea4b925ae936626d00c984e4691186891f5bc16"]' -s -d \
    -p eosio@active --json-file ${ACTIONS_DIR}/activate-disable-deferred-2-action.json --expiration 8640000
# BLS_PRIMITIVES2
cleos --url $ENDPOINT push action eosio activate '["63320dd4a58212e4d32d1f58926b73ca33a247326c2a5e9fd39268d2384e011a"]' -s -d \
    -p eosio@active --json-file ${ACTIONS_DIR}/activate-bls-primitives-2-action.json --expiration 8640000
# SAVANNA
cleos --url $ENDPOINT push action eosio activate '["cbe0fafc8fcc6cc998395e9b6de6ebd94644467b1b4a97ec126005df07013c52"]' -s -d \
    -p eosio@active --json-file ${ACTIONS_DIR}/activate-savanna.json --expiration 8640000


# CREATE EMPTY SHELL TRANSACTION THAT WILL HOLD OUR ACTIONS
cat ${ACTIONS_DIR}/activate-disable-deferred-1-action.json | jq 'del(.actions)' | head -8 > ${ACTIONS_DIR}/start-shell-transaction.json
cat ${ACTIONS_DIR}/activate-disable-deferred-1-action.json | jq 'del(.actions)' | tail -4 > ${ACTIONS_DIR}/end-shell-transaction.json

# using our shell create new transaction with many inline actions
cp  ${ACTIONS_DIR}/start-shell-transaction.json ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
# open actions array
printf '"actions": [' >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json

# append actions with comma sep
if [ $NETWORK == "KYLIN" ]; then
  for file in time.json activate-bls-primitives-2-action.json
  do
    cat ${ACTIONS_DIR}/${file} | jq '.actions[]' >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
    printf "," >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
    rm ${ACTIONS_DIR}/${file}
  done
  rm ${ACTIONS_DIR}/activate-disable-deferred-1-action.json ${ACTIONS_DIR}/activate-disable-deferred-2-action.json
fi

if [ $NETWORK == "MAINNET" ]; then
  for file in time.json activate-disable-deferred-1-action.json activate-disable-deferred-2-action.json activate-bls-primitives-2-action.json
  do
    cat ${ACTIONS_DIR}/${file} | jq '.actions[]' >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
    printf "," >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
    rm ${ACTIONS_DIR}/${file}
  done
fi

if [ $NETWORK == "LOCAL" ]; then
  for file in time.json activate-bls-primitives-2-action.json
  do
    cat ${ACTIONS_DIR}/${file} | jq '.actions[]' >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
    printf "," >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
    rm ${ACTIONS_DIR}/${file}
  done
  rm ${ACTIONS_DIR}/activate-disable-deferred-1-action.json ${ACTIONS_DIR}/activate-disable-deferred-2-action.json
fi

# activate SAVANNA protocol feature to enable upgraded consensus
cat ${ACTIONS_DIR}/activate-savanna.json | jq '.actions[]' >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
# close actions array
echo '],' >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
# close our transaction
cat ${ACTIONS_DIR}/end-shell-transaction.json >> ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json
cat ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json | jq > /tmp/pretty.json
mv /tmp/pretty.json ${ACTIONS_DIR}/PREPARE_SAVANNA_ACTIONS.json

###############
## SECOND TRX
## spr2.contract
## SET SYSTEM CONTRACT CODE AND ABI
###############
cleos --url $ENDPOINT set contract eosio ${EOS_CONTRACT_DIR}/eosio.system eosio.system.wasm eosio.system.abi -s -d \
    -p eosio@active --json-file ${ACTIONS_DIR}/SETCONTRACT.json --expiration 8640000

###############
## THIRD TRX
## spr3.switcht
## SWTICHTOSVNN
###############
cleos --url $JUNGLE push action eosio switchtosvnn '{}' -s -d \
     -p eosio@active --json-file ${ACTIONS_DIR}/switchtosvnn.json --expiration 8640000

cp ${ACTIONS_DIR}/time.json ${ACTIONS_DIR}/SWITCH_TO_SVNN.json
SWITCH_ACTION=$(jq '.actions[0]' ${ACTIONS_DIR}/switchtosvnn.json)
jq ".actions[0] += ${SWITCH_ACTION}" ${ACTIONS_DIR}/SWITCH_TO_SVNN.json > /tmp/pretty.json
mv /tmp/pretty.json ${ACTIONS_DIR}/SWITCH_TO_SVNN.json

# clean up files we don't need
rm ${ACTIONS_DIR}/start-shell-transaction.json ${ACTIONS_DIR}/end-shell-transaction.json ${ACTIONS_DIR}/activate-savanna.json ${ACTIONS_DIR}/time.json
