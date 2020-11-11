#!/bin/bash
#Assumes that VAULT_ADDR and VAULT_TOKEN has been set in environmental variables for the "Production" Vault connection
#Set the address to the Transit Vault (or vault you wish to unlock automatically)
TRANSIT_VAULT=<URL to Transit Vault>
#Renew the current vault token, which must have access to the secrets path where the unseal keys are stored
vault token renew &>/dev/null
#Check Transit Vault seal status
vault_status=$(VAULT_ADDR=$TRANSIT_VAULT vault status -format "json" | jq --raw-output '.sealed')
if [[ $vault_status == 'false' ]]; then
        :
elif [[ $vault_status == 'true' ]]; then
		#Create keys array to temporarily store keys grabbed from the Production Vault (assumes key values are Key1, Key2, etc.)
        declare -A keys
        keys+=(["key1"]='' ["key2"]='' ["key3"]='' ["key4"]='' ["key5"]='')
		#Grab unseal key values from Production Vault and store them in the array
        for key in ${!keys[@]}; do
                keys[${key}]=$(vault kv get -field=${key} secrets/transit-vault);
        done
		#Run unseal operation and iterate through the key values until the seal status changes to "false"
        i=1
        while [[ $vault_status == 'true' ]];
                do
                VAULT_ADDR=$TRANSIT_VAULT vault operator unseal ${keys[key$i]} &>/dev/null
                vault_status=$(VAULT_ADDR=$TRANSIT_VAULT vault status -format "json" | jq --raw-output '.sealed')
                i=$[$i+1]
        done
else
        :
fi