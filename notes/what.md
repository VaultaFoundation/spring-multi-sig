
# Activate Defered Transactions
### DISABLE_DEFERRED_TRXS_STAGE_1
cleos --url $ENDPOINT push action eosio activate '["fce57d2331667353a0eac6b4209b67b843a7262a848af0a49a6e2fa9f6584eb4"]' -p eosio
#### DISABLE_DEFERRED_TRXS_STAGE_2
cleos --url $ENDPOINT push action eosio activate '["09e86cb0accf8d81c9e85d34bea4b925ae936626d00c984e4691186891f5bc16"]' -p eosio
### BLS_PRIMITIVES2
cleos --url $ENDPOINT push action eosio activate '["63320dd4a58212e4d32d1f58926b73ca33a247326c2a5e9fd39268d2384e011a"]' -p eosio
### SAVANNA
cleos --url $ENDPOINT push action eosio activate '["cbe0fafc8fcc6cc998395e9b6de6ebd94644467b1b4a97ec126005df07013c52"]' -p eosio
