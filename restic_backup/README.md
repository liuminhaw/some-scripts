# Restic Backup
Automation backup using restic

## Pre-requisite
restic need to be installed before using this script  
**reference:** [Installation](https://restic.readthedocs.io/en/latest/020_installation.html)

## Version 
### V0.0.2
- Init backup repository with `--init` option
- Fis Issue #8 [restic-bkp setup script mismatch file]

#### v0.0.1
- Execute restic backup with repositories:
    - `local` destination
    - `sftp` destination
- Show snapshots with repositories:
    - `local` destination
    - `sftp` destination

## Setup
#### Configuration
Set backup information (source, destination, password, exclusion)

#### Usage
```
Usage: restic-backup.sh [--help] [--version] [--snapshots|--init] [--type=local|sftp]
    --help                      Display this help message and exit
    --snapshots                 Display snapshot history from 'type' destination
    --init                      Initial backup destination
    --type=[local|sftp]         
    --type [local|sftp]         Specify backup destination type: (local, sftp)
                                Default type: local
    --version                   Show version information
```

#### Exclusion
Set `_EXCLUDE_FILE` variable in config file, and create the file with listed files and directories for exclusion
```
List
excluded 
files
and
diretories
here
``` 

#### Password
Password is needed when restic create snapshots
Set `_PASSWORD_FILE` variable in config file, create the file and insert the password
```
defaultPasswordToEncryptResticSnapshot
```
