# vault_unseal
Bash script to auto-unseal secondary vault (Transit Vault) using unseal keys in production vault.
This script fits a very specific need; to automatically unseal a secondary (Transit Vault) if it goes down without needing manual intervention.  It assumes that the Production Vault or cluster is still available.
## Hashicorp does not recommend using a method like this to unseal a production vault for obvious security reasons.
### Prerequisites:
  - Production Vault environment (HA or standalone) properly secured which is using auto-unseal with Transit Engine in a standalone separate Vault instance (Transit Vault). 
  - KV Secrets location which has all unseal keys for the Transit Vault with keys as Key1, Key2, Key3, etc.
  - A token issued to the server running the Transit Vault which has access to the KV secret location where the unseal keys are stored

You can modify this script easily to use fewer unseal keys if your shamir key share is less than 5 (or more)
