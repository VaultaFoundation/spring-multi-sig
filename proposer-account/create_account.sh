#!/usr/bin/env bash

ACCOUNT=proposer.enf
CREATOR=enf
PROPER_NAME=$(echo $ACCOUNT | cut -d'.' -f1)
ENDPOINT=http://127.0.0.1:8888
MSIG_PROP_ACCOUNT=spaceranger1
CHAIN=${1:-LOCAL}
if [ $CHAIN == "LOCAL" ]; then 
    CHAIN = "-local"
else 
    if
fi

PUB_KEY=$(grep Public $HOME/eosio-wallet/${ACCOUNT}${CHAIN}.keys | cut -d: -f2 | sed 's/\s//')

if [ $NETWORK == "JUNGLE" ]; then
  ENDPOINT=https://jungle4.cryptolions.io:443
  MSIG_PROP_ACCOUNT=hokieshokies
  KEYS=$HOME/eosio-wallet/${ACCOUNT}-jungle.keys
fi

if [ $NETWORK == "KYLIN" ]; then
  ENDPOINT=https://api.kylin.alohaeos.com
  MSIG_PROP_ACCOUNT=spacerang.gm
  $HOME/eosio-wallet/${ACCOUNT}-kylin.keys
fi

if [ $NETWORK == "MAINNET" ]; then
  ENDPOINT=https://eos.api.eosnation.io
  MSIG_PROP_ACCOUNT=ericpassmore
  $HOME/eosio-wallet/${ACCOUNT}.keys
fi

if [ ! -s $KEYS ]; then
  echo "Can not find $KEYS"
  exit
fi

PUB_KEY=$(grep Public $KEYS | cut -d: -f2 | sed 's/\s//')
cat > ./${PROPER_NAME}_active_auth.json << EOF
{
    "threshold": 1,
    "keys": [{
        "key": "${PUB_KEY}",
        "weight": 1
    }],
    "accounts": [{
        "permission": {
            "actor": "enf",
            "permission": "active"
        },
        "weight": 1
    }],
    "waits": []
}
EOF
ACTIVE_AUTH_JSON=$(cat ./${PROPER_NAME}_active_auth.json)

cat > ./${PROPER_NAME}_owner_auth.json << EOF
{
    "threshold": 1,
    "keys": [],
    "accounts": [{
        "permission": {
            "actor": "enf",
            "permission": "owner"
        },
        "weight": 1
    }],
    "waits": []
}
EOF
OWNER_AUTH_JSON=$(cat ./${PROPER_NAME}_owner_auth.json)

cleos -u $ENDPOINT system newaccount $CREATOR $ACCOUNT \
"${OWNER_AUTH_JSON}" "${ACTIVE_AUTH_JSON}" --stake-net "0.0 EOS" --stake-cpu "0.0 EOS" --buy-ram-kbytes 1000 \
-p ${CREATOR}@active -s -d --json-file ./CREATE_${PROPER_NAME}_ENF_USER.json --expiration 8640000

cleos -u $ENDPOINT transfer $CREATOR $ACCOUNT "3 EOS" "transfer for powerup" \
-p ${CREATOR}@active -s -d --json-file ./FUNDING_${PROPER_NAME}.json --expiration 8640000
TRANS_ACTION=$(jq '.actions[0]' ./FUNDING_${PROPER_NAME}.json)

jq ".actions[2] += ${TRANS_ACTION}" ./CREATE_${PROPER_NAME}_ENF_USER.json > /tmp/pretty.json

mv /tmp/pretty.json ./CREATE_${PROPER_NAME}_ENF_USER.json

eosc -u $ENDPOINT multisig propose $MSIG_PROP_ACCOUNT createenfusr \
    ./CREATE_${PROPER_NAME}_ENF_USER.json \
    --request admin1.enf --request admin2.enf --request admin3.enf --request admin4.enf \
    --vault-file $HOME/eosio-wallet/.eosc-vault-${MSIG_PROP_ACCOUNT}.json
