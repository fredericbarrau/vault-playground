# Vault encrypt files with Transit


## Usage

* Start a vault server + the terraform configuration with : `scripts/start-vault.sh``

### Encryption / Decryption

* Encrypt with `scripts/encrypt-file.sh`
* Decrypt with `script/decrypt-file.sh`

### Rotate key

```console
$ vault write -f transit/keys/my_application/rotate
```

=> Data will be **encrypted** with a new key

Chech the number of currently encryption keys :

```console
$ vault read -format=json -field=keys transit/keys/my_application 
```

Disallow the earlier key by setting the min encryption key id:

```console
vault write -f transit/keys/my_application/config min_decryption_version=2
```

Now decryption of a file previously encrypted with key one will be disallowed:

```console
─$ ./decrypt-file.sh ../data/vault-logo.png.20220827-121128.encrypted
Error writing data to transit/decrypt/my_application: Error making API request.

URL: PUT http://localhost:8200/v1/transit/decrypt/my_application
Code: 400. Errors:

* ciphertext or signature version is disallowed by policy (too old)
Failed to decrypt ../data/vault-logo.png.20220827-121128.encrypted

```

Keys are not removed, it is possible to re-allow encryption key 1 by lowering `min_decryption_version` again


## Documentation

* https://www.vaultproject.io/docs/secrets/transit
* https://learn.hashicorp.com/tutorials/vault/eaas-transit