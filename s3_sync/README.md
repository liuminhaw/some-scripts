# S3 Sync
Sync directory to s3 bucket

## Version
### v0.1.1
- `--config` option specify config file to read

#### v0.1.0
- sync `push` (sync from local to s3)
- sync `pull` (sync from s3 to local)

## Configuration
`config` file should be exist in current working directory for the script to read configuration information.

Details for configuration can be referenced in `config.template` file

## Usage
```
Usage: s3-sync.sh [--help] [--version] [--config=CONFIG_FILE] pull|push
    --help                      Display this help message and exit
    --version                   Show version information
    --config=CONFIG_FILE        Specify which config file to read from
    pull                        Sync from S3 bucket to local
    push                        Sync from local to S3 bucket
```


## Exit code
1 - Usage error
2 - Missing config