#!/bin/env bash

cat ./eosio-wallet/finality-test-network-wallet.pw | cleos wallet unlock -n finality-test-network-wallet
cat > $HOME/required_auth.json << EOF
{
  "threshold": 2,
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
