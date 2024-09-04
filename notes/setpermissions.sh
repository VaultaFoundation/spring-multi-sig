#!/bin/env bash

cat ./eosio-wallet/finality-test-network-wallet.pw | cleos wallet unlock -n finality-test-network-wallet
cat > $HOME/required_auth.json << EOF
{
  "threshold": 3,
  "keys": [],
  "accounts": [
    {
      "permission": {
        "actor": "bpa",
        "permission": "active"
      },
      "weight": 1
    },
    {
      "permission": {
        "actor": "bpb",
        "permission": "active"
      },
      "weight": 1
    },
    {
      "permission": {
        "actor": "bpc",
        "permission": "active"
      },
      "weight": 1
    }
  ],
  "waits": []
}
EOF
cleos set account permission eosio active $HOME/required_auth.json

ACCOUNT=spaceranger1
PUB_KEY=$(grep Public ~/eosio-wallet/${ACCOUNT}.keys | cut -d: -f2 | sed 's/\s//')
cat > $HOME/required_auth2.json << EOF
{
  "threshold": 1,
  "keys": [{
    "key": "${PUB_KEY}",
    "weight": 1
  }
  ],
  "accounts": [
    {
      "permission": {
        "actor": "enf.signator",
        "permission": "active"
      },
      "weight": 1
    }
  ],
  "waits": []
}
EOF
cleos set account permission spaceranger1 active $HOME/required_auth2.json
