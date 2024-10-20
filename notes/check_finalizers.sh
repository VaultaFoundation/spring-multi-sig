#!/bin/bash

for p in atticlabeosb  aus1genereos big.one binancestake blockpooleos bp.defi eoscannonchn  eoseouldotio eosflytomars eosinfstones eosiodetroit eosiosg11111 eoslaomaocom eosnationftw eosphereiobp eostitanprod hashfineosio ivote4eosusa newdex.bp starteosiobp teamgreymass
do
  echo -n "$p :"
  cleos get table --limit 100 eosio eosio finalizers | jq '.rows[]' | jq  "select (.finalizer_name==\"${p}\")"
done
