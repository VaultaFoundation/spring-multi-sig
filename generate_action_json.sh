#!/bin/env bash

NETWORK=${1:-LOCAL}
CONTRACT_DIR="/local/eosnetworkfoundation/repos/eos-system-contracts/build/contracts"

ENDPOINT=http://127.0.0.1:8888
JUNGLE=https://jungle4.cryptolions.io:443

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
fi

###############
## FIRST TRX
## FEATURE ACTIVATIONS
## SYS CONTRACT UPDATE
###############
## CREATE JSON TRANSACTIONS FOR FEATURE ACTIVATIONS
# DISABLE_DEFERRED_TRXS_STAGE_1
cleos --url $ENDPOINT push action eosio activate '["fce57d2331667353a0eac6b4209b67b843a7262a848af0a49a6e2fa9f6584eb4"]' -s -d \
    --json-file ${CONTRACT_DIR}/activate-disable-deferred-1-action.json --expiration 8640000
# DISABLE_DEFERRED_TRXS_STAGE_2
cleos --url $ENDPOINT push action eosio activate '["09e86cb0accf8d81c9e85d34bea4b925ae936626d00c984e4691186891f5bc16"]' -s -d \
    --json-file ${CONTRACT_DIR}/activate-disable-deferred-2-action.json --expiration 8640000
# BLS_PRIMITIVES2
cleos --url $ENDPOINT push action eosio activate '["63320dd4a58212e4d32d1f58926b73ca33a247326c2a5e9fd39268d2384e011a"]' -s -d \
    --json-file ${CONTRACT_DIR}/activate-bls-primitives-2-action.json --expiration 8640000
# SAVANNA
cleos --url $ENDPOINT push action eosio activate '["cbe0fafc8fcc6cc998395e9b6de6ebd94644467b1b4a97ec126005df07013c52"]' -s -d \
    --json-file ${CONTRACT_DIR}/activate-savanna.json --expiration 8640000
# SET SYSTEM CONTRACT CODE AND ABI
cleos --url $ENDPOINT set contract eosio ${CONTRACT_DIR}/eosio.system eosio.system.wasm eosio.system.abi -s -d \
    --json-file ${CONTRACT_DIR}/setcontract-eosio.system.json --expiration 8640000

# CREATE EMPTY SHELL TRANSACTION THAT WILL HOLD OUR ACTIONS
cat ${CONTRACT_DIR}/activate-disable-deferred-1-action.json | jq 'del(.actions)' | head -8 > ${CONTRACT_DIR}/start-shell-transaction.json
cat ${CONTRACT_DIR}/activate-disable-deferred-1-action.json | jq 'del(.actions)' | tail -4 > ${CONTRACT_DIR}/end-shell-transaction.json

# using our shell create new transaction with many inline actions
cp  ${CONTRACT_DIR}/start-shell-transaction.json ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json
# open actions array
printf '"actions": [' >> ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json
# append actions with comma sep
for file in activate-disable-deferred-1-action.json activate-disable-deferred-2-action.json activate-bls-primitives-2-action.json activate-savanna.json
do
  cat ${CONTRACT_DIR}/${file} | jq '.actions[]' >> ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json
  printf "," >> ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json
  rm ${CONTRACT_DIR}/${file}
done
# add system contract set code action
cat ${CONTRACT_DIR}/setcontract-eosio.system.json | jq '.actions[0]' >> ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json
printf "," >> ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json
# add system contract set abi action
cat ${CONTRACT_DIR}/setcontract-eosio.system.json | jq '.actions[1]' >> ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json
# close actions array
echo '],' >> ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json
# close our transaction
cat ${CONTRACT_DIR}/end-shell-transaction.json >> ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json
cat ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json | jq > /tmp/pretty.json
mv /tmp/pretty.json ${CONTRACT_DIR}/PREPARE_SAVANNA_ACTIONS.json

###############
## SECOND TRX
## SWTICHTOSVNN
###############
cleos --url $JUNGLE push action eosio switchtosvnn '{}' -s -d --json-file ${CONTRACT_DIR}/switchtosvnn.json --expiration 8640000
# using our shell create new transaction with many inline actions
cp  ${CONTRACT_DIR}/start-shell-transaction.json ${CONTRACT_DIR}/SWITCH_TO_SVNN.json
# open actions array
printf '"actions": [' >> ${CONTRACT_DIR}/SWITCH_TO_SVNN.json
# append actions with comma sep
cat ${CONTRACT_DIR}/switchtosvnn.json | jq '.actions[]' >> ${CONTRACT_DIR}/SWITCH_TO_SVNN.json
printf "," >> ${CONTRACT_DIR}/SWITCH_TO_SVNN.json
rm ${CONTRACT_DIR}/switchtosvnn.json

# add system contract set code action
cat ${CONTRACT_DIR}/setcontract-eosio.system.json | jq '.actions[0]' >> ${CONTRACT_DIR}/SWITCH_TO_SVNN.json
printf "," >> ${CONTRACT_DIR}/SWITCH_TO_SVNN.json
# add system contract set abi action
cat ${CONTRACT_DIR}/setcontract-eosio.system.json | jq '.actions[1]' >> ${CONTRACT_DIR}/SWITCH_TO_SVNN.json
# close actions array
echo '],' >> ${CONTRACT_DIR}/SWITCH_TO_SVNN.json
# close our transaction
cat ${CONTRACT_DIR}/end-shell-transaction.json >> ${CONTRACT_DIR}/SWITCH_TO_SVNN.json
cat ${CONTRACT_DIR}/SWITCH_TO_SVNN.json | jq > /tmp/pretty.json
mv /tmp/pretty.json ${CONTRACT_DIR}/SWITCH_TO_SVNN.json

# clean up files we don't need
rm ${CONTRACT_DIR}/start-shell-transaction.json ${CONTRACT_DIR}/end-shell-transaction.json ${CONTRACT_DIR}/setcontract-eosio.system.json
