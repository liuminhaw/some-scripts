# Restic Backup
Automation backup using restic

## Pre-requisite
restic need to be installed before using this script  
**reference:** [Installation](https://restic.readthedocs.io/en/latest/020_installation.html)

## Version 
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
