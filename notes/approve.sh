#!/bin/env bash

cat ~/eosio-wallet/finality-test-network-wallet.pw | cleos wallet unlock -n finality-test-network-wallet
ACCOUNT=spaceranger1
SIG=${1:-enfsys.ric}
# spr2.contrac
# spr3.switcht
cleos multisig approve $ACCOUNT $SIG '{"actor": "bpa", "permission": "active"}' -p bpa@active
cleos multisig approve $ACCOUNT $SIG '{"actor": "bpb", "permission": "active"}' -p bpb@active
cleos multisig approve $ACCOUNT $SIG '{"actor": "bpc", "permission": "active"}' -p bpc@active
