# S3 Sync
Sync directory to s3 bucket

## Version
### v0.2.0
- `--age` option to encrypt files with age before upload
- `--age` option to decrypt files with age after download

#### v0.1.1
- `--config` option specify config file to read

#### v0.1.0
- sync `push` (sync from local to s3)
- sync `pull` (sync from s3 to local)

## Pre-requisite
`age` need to be installed if using `--age` option to encrypt/decrypt files: [age](https://github.com/FiloSottile/age/releases)

### age key generation
Private key file
```sh
age-keygen -o keyname.key
```
Public key file
```sh
# put age-keygen generated output (public key) to file - keyname.pub
echo "public key content" > keyname.pub
```

## Configuration
`config` file should be exist in current working directory for the script to read configuration information, or specify config file with `--config` option.

Details for configuration can be referenced in `config.template` file

## Usage
```
Usage: s3-sync.sh [--help] [--version] [--config=CONFIG_FILE] [--age=AGE_KEYFILE] pull|push
    --help                      Display this help message and exit
    --version                   Show version information
    --config=CONFIG_FILE        Specify which config file to read from
                                Default file: config
    --age=AGE_KEYFILE           Add encryption with age using key file 
    pull                        Sync from S3 bucket to local
    push                        Sync from local to S3 bucket
```

**push with encryption**
```sh
s3-sync.sh --age keyname.pub push
```

**pull with decryption**
```sh
s3-sync.sh --age keyname.key pull
```


## Exit code
1 - Usage error  
2 - Missing config  
3 - age usage error  
4 - internal function usage error