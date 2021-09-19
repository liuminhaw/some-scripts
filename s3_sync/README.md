# S3 Sync
Sync directory to s3 bucket

## Version
### v0.2.0
- `--age` option
    - encrypt files with `age` program before sync push
    - decrypt files with `age` program after sync pull
- `--file-perm` option to set files permission after sync pull
- `--dir-perm` option to set directories permission after sync pull

#### v0.1.1
- `--config` option specify config file to read

#### v0.1.0
- sync `push` (sync from local to s3)
- sync `pull` (sync from s3 to local)

## Pre-requisite
`age` need to be installed if using `--age` option to encrypt/decrypt files: [age](https://github.com/FiloSottile/age/releases)

### age key generation
 Generate private key file
```sh
age-keygen -o keyname.key
```
Generate public key file
```sh
# put age-keygen generated output (public key) to file - keyname.pub
echo "public key content" > keyname.pub
```

## Configuration
`config` file should be exist in current working directory for the script to read configuration information, or specify config file with `--config` option.

Details for configuration can be referenced in `config.template` file

## Usage
```
Usage: 
s3-sync.sh [--help] [--version] [--config=CONFIG_FILE] [--age=AGE_KEYFILE] push
s3-sync.sh [--help] [--version] [--config=CONFIG_FILE] [--age=AGE_KEYFILE] [--file-perm=NUMERIC_PERM] [--dir-perm=NUMERIC_PERM] pull
    --help                          Display this help message and exit
    --version                       Show version information
    --config=CONFIG_FILE            Specify which config file to read from
                                    Default file: config
    --age=AGE_KEYFILE               Add encryption with age using key file 
    --file-perm=NUMERIC_PERM        Set files permission to NUMERIC_PERM (Eg. 664) 
    --dir-perm=NUMERIC_PERM         Set directory permission to NUMERIC_PERM (Eg. 775)
    pull                            Sync from S3 bucket to local
    push                            Sync from local to S3 bucket
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