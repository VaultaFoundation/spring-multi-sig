#!/bin/env bash

NETWORK=${1:-LOCAL}
WITHTIME=${2:-YES}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ACTIONS_DIR="${SCRIPT_DIR}/../actions"
if [ ! -d $ACTIONS_DIR ]; then
  echo "${ACTIONS_DIR} does not exist"
  exit
fi

ENDPOINT=http://127.0.0.1:8888
ACCOUNT=spaceranger1
TO=bpa
REQUEST="enf.signator"

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
  ACCOUNT=spacerang.gm
  TO=ivote4eosusa
  REQUEST=kylinsignora
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
  ACCOUNT=enf.proposer
  TO=ivote4eosusa
fi

# specific date date -u -d "2030-01-01 00:00:00" +"%Y-%m-%dT%H:%M:%S.000"
TIME=$(date -u -d "3 minutes" +"%Y-%m-%dT%H:%M:%S")
cleos push action eosio.time checktime "[\"${TIME}\"]" -p ${ACCOUNT}@active -s -d --json-file ${ACTIONS_DIR}/time.json --expiration 8640000


cleos transfer $ACCOUNT $TO "0.001 EOS" "very small trx" -p ${ACCOUNT}@active -s -d --json-file ${ACTIONS_DIR}/verysmalltrans.json --expiration 8640000
if [ $WITHTIME == "YES" ]; then
  cat ${ACTIONS_DIR}/verysmalltrans.json | jq 'del(.actions)' | head -8 > ${ACTIONS_DIR}/test-start-shell-transaction.json
  cat ${ACTIONS_DIR}/verysmalltrans.json | jq 'del(.actions)' | tail -4 > ${ACTIONS_DIR}/test-end-shell-transaction.json
  # using our shell create new transaction with many inline actions
  cp  ${ACTIONS_DIR}/test-start-shell-transaction.json ${ACTIONS_DIR}/TEST.json
  # open actions array
  printf '"actions": [' >> ${ACTIONS_DIR}/TEST.json
  cat $ACTIONS_DIR/time.json | jq .actions[] >> ${ACTIONS_DIR}/TEST.json
  printf "," >> ${ACTIONS_DIR}/TEST.json
  cat $ACTIONS_DIR/verysmalltrans.json | jq .actions[] >> ${ACTIONS_DIR}/TEST.json
  # close actions array
  echo '],' >> ${ACTIONS_DIR}/TEST.json
  # close our transaction
  cat ${ACTIONS_DIR}/test-end-shell-transaction.json >> ${ACTIONS_DIR}/TEST.json
  cat ${ACTIONS_DIR}/TEST.json | jq > /tmp/pretty.json
  mv /tmp/pretty.json ${ACTIONS_DIR}/TEST.json
  rm ${ACTIONS_DIR}/test-start-shell-transaction.json ${ACTIONS_DIR}/test-end-shell-transaction.json
  rm ${ACTIONS_DIR}/verysmalltrans.json $ACTIONS_DIR/time.json
else
  mv ${ACTIONS_DIR}/verysmalltrans.json ${ACTIONS_DIR}/TEST.json
  rm $ACTIONS_DIR/time.json
fi

eosc -u $ENDPOINT multisig propose $ACCOUNT smalltrxb ${ACTIONS_DIR}/TEST.json --request $REQUEST --vault-file .eosc-vault-${ACCOUNT}.json
