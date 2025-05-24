# Post System Contracts to Jungle as MSIG

Summary: Create and post an MSIG on Jungle to run `setcode` and `setabi` actions for system contracts updates. The MSIG approvers are the top 21 block producers. 15 of the 21 must approve the MSIG so that it may be executed. 

### Step 1: build contracts 
Build the system contracts following [instructions here](https://github.com/VaultaFoundation/system-contracts/). Make sure the dependancies like Spring and CDT are build to the correct version. 

### Step 2: create transaction as JSON 
Needed Inputs 
- Jungle Endpoint `ENDPOINT=https://jungle4.cryptolions.io:443`
- Directory to Store Actions `ACTIONS_DIR=~/actions`
- Contract Directory `CONTRACT_DIR=/local/VaultaFoundation/repos/system-contracts/build/contracts`
- Run command to create JSON version of transaction, does not execute on chain
```
cleos -u $ENDPOINT set contract eosio ${CONTRACT_DIR}/eosio.system eosio.system.wasm eosio.system.abi -s -d \
     -p eosio@active --expiration 8640000 --json-file ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.9.0.JSON
```

### Step3 : powerup for added reasources 
Needed Inputs
- The Account `ACCOUNT=proposer.enf`

`cleos -u $ENDPOINT push action eosio powerup "[${ACCOUNT}, ${ACCOUNT}, 1, 1000000000, 1000000000, \"1.0000 EOS\"]" -p ${ACCOUNT}`

### Step 4: post MSIG on chain 
Needed dependancies `eosc`. 
- [Download and build from `eoscanada/eosc`](https://github.com/eoscanada/eosc).This client has a convenient method to pull in the block producers. 

Needed Inputs
- The Account `ACCOUNT=proposer.enf`
- The eosc vault file `VAULT="junglevault"`
- Name of your multi sig. `SIG="enfsys.390"`
- Private key for Account `proposer.enf` 

If your `eosc` vault does not exist create it, providing the private key 
```
if [ ! -s $HOME/eosio-wallet/.eosc-${VAULT}-${ACCOUNT}.json ]; then
    eosc vault create --vault-file $HOME/eosio-wallet/.eosc-${VAULT}-${ACCOUNT}.json --import
fi
``` 

Now send out the contract as an MSIG 
```
# Error check on JSON 
cat ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.9.0.JSON | jq 1> /dev/null
if [ $? != 0 ]; then
    echo "ERROR: invalid JSON  EXITING"
    # exit
fi
eosc -u $ENDPOINT multisig propose $ACCOUNT $SIG \
    ${ACTIONS_DIR}/EOSIO_SYSTEM_v3.9.0.JSON \
    --request-producers --vault-file $HOME/eosio-wallet/.eosc-${VAULT}-${ACCOUNT}.json
 ```

### Step 5: Validate MSIG 
Use the Unicove MSIG tools. Need to sign into Unicove to see the msig
- https://jungle4.unicove.com/en/jungle4/msig/proposer.enf/${SIG} 
In this example the URL would be
- https://jungle4.unicove.com/en/jungle4/msig/proposer.enf/enfsys.per

In production this URL would be
- https://unicove.com/en/vaulta/msig/proposer.enf/enfsys.per

### Cancel on MSIG
If needed here is how you cancel. Need to add private key for $ACCOUNT to your wallet 
`cleos --url $ENDPOINT multisig cancel $ACCOUNT $SIG $ACCOUNT`

