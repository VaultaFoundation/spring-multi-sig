#!/bin/env bash

CHAIN=${1:-LOCAL}
if [ $CHAIN == "LOCAL" ]; then 
    CHAIN="-local"
fi

cat ./eosio-wallet/finality-test-network-wallet.pw | cleos wallet unlock -n finality-test-network-wallet
cat > $HOME/required_auth.json << EOF
{
  "threshold": 2,
  "keys": [
    {
      "key": "EOS5mCN9hNuHieDcGviVNvfCiq6m2KB7cgjSqGTeDmN74s2MwhCpF",
      "weight": 2
    },
    {
      "key": "EOS77aqrnWUFvjCNxonxGd9vF3LtWCN54dU2NDCa8F2bgP8Ca4xcp",
      "weight": 2
    }
  ],
  "accounts": [
    {
      "permission": {
        "actor": "eosio.prods",
        "permission": "active"
      },
      "weight": 2
    },
    {
      "permission": {
        "actor": "eosnationftw",
        "permission": "active"
      },
      "weight": 1
    },
    {
      "permission": {
        "actor": "ivote4eosusa",
        "permission": "active"
      },
      "weight": 1
    }
  ],
  "waits": []
}
EOF
cleos set account permission eosio active $HOME/required_auth.json

ACCOUNT=proposer.enf
PUB_KEY=$(grep Public ~/eosio-wallet/${ACCOUNT}${CHAIN}.keys | cut -d: -f2 | sed 's/\s//')
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
        "actor": "proposer.enf",
        "permission": "active"
      },
      "weight": 1
    }
  ],
  "waits": []
}
EOF
cleos set account permission $ACCOUNT active $HOME/required_auth2.json
