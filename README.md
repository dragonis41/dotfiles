# dotfiles
My personal dotfiles with custom backup and restore script.

## Features
### save_manjaro.sh
It will :
- Do a backup of all files listed in it.
- Create a database with the path of all files and theirs permissions.

### restore_manjaro.sh
It will :
- Install base packages
- Install extra packages
- Install oh-my-zsh
- Install and configure fingerprint authentication
- Install and configure Yubikey
- Restore configuration files

### permissions_xyz.db
Do not touch !\
Permissions and paths are stored in this file.

### config/
The folder where backups are stored
