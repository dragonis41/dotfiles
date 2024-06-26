#!/bin/bash

if [ "$EUID" -ne 0 ] || [ "$SUDO_USER" = "" ]; then
    echo "Please run as sudo but not as root"
    exit
fi

##################################################
# VARIABLES
##################################################
# Name of the database where permissions, owners and paths are stored.
database="permissions_manjaro.db"
# Folder where the files will be saved.
backup_folder="config/Manjaro"
# Full path of files to save.
# Format: "source:dest" where source is a file and dest is a folder.
files=(
    ####################### User config files #######################
    "/home/dragonis41/.bashrc:${backup_folder}/dragonis41/"
    "/home/dragonis41/.config/htop/htoprc:${backup_folder}/dragonis41/.config/htop/"
    "/home/dragonis41/.config/kglobalshortcutsrc:${backup_folder}/dragonis41/.config/"
    "/home/dragonis41/.gitconfig:${backup_folder}/dragonis41/"
    "/home/dragonis41/.gnupg/gpg-agent.conf:${backup_folder}/dragonis41/.gnupg/"
    "/home/dragonis41/.gnupg/public.key:${backup_folder}/dragonis41/.gnupg/"
    "/home/dragonis41/.local/share/konsole/Custom.profile:${backup_folder}/dragonis41/.local/konsole/"
    "/home/dragonis41/.nanorc:${backup_folder}/dragonis41/"
    "/home/dragonis41/.p10k.zsh:${backup_folder}/dragonis41/"
    "/home/dragonis41/.ssh/config:${backup_folder}/dragonis41/.ssh/"
    "/home/dragonis41/.zshrc:${backup_folder}/dragonis41/"

    ########################### Git Hooks ###########################
    # Pre commit
    "/home/dragonis41/.git-hooks/pre-commit:${backup_folder}/dragonis41/.git-hooks/"
    "/home/dragonis41/.git-hooks/pre-commit.d/01.check-for-private-key.hook:${backup_folder}/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/02.check-for-env-files.hook:${backup_folder}/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/03.check-for-credentials.hook:${backup_folder}/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/04.remove-trailing-space.hook:${backup_folder}/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/05.fix-end-of-files.hook:${backup_folder}/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/06.format-go-files.hook:${backup_folder}/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/07.validate-json-files.hook:${backup_folder}/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/08.validate-xml-files.hook:${backup_folder}/dragonis41/.git-hooks/pre-commit.d/"
    # Commit msg
    "/home/dragonis41/.git-hooks/commit-msg:${backup_folder}/dragonis41/.git-hooks/"
    "/home/dragonis41/.git-hooks/commit-msg.d/01.check-message.hook:${backup_folder}/dragonis41/.git-hooks/commit-msg.d/"
    # Post update
    "/home/dragonis41/.git-hooks/post-update:${backup_folder}/dragonis41/.git-hooks/"
    "/home/dragonis41/.git-hooks/post-update.d/01.update-server-info.hook:${backup_folder}/dragonis41/.git-hooks/post-update.d/"

    ############################ System #############################
    "/etc/issue:${backup_folder}/etc/"
    "/etc/pacman.conf:${backup_folder}/etc/"
    "/etc/pam.d/system-auth:${backup_folder}/etc/pam.d/"
    "/etc/sudoers.d/timeout:${backup_folder}/etc/sudoers.d/"
    "/etc/sudoers.d/editor:${backup_folder}/etc/sudoers.d/"
    "/etc/udev/rules.d/99-via.rules:${backup_folder}/etc/udev/"
    # Config for Nvidia graphic card
    "/etc/optimus-manager/optimus-manager.conf:${backup_folder}/etc/optimus-manager/"
    "/etc/X11/xorg.conf.d/10-optimus-manager.conf:${backup_folder}/etc/X11/xorg.conf.d/"
    "/etc/sddm.conf:${backup_folder}/etc/"

    ####################### Root config files #######################
    "/root/.bashrc:${backup_folder}/root/"
    "/root/.config/htop/htoprc:${backup_folder}/root/"
    "/root/.nanorc:${backup_folder}/root/"
    "/root/.p10k.zsh:${backup_folder}/root/"
    "/root/.zshrc:${backup_folder}/root/"
)


##################################################
# FUNCTIONS
##################################################
function mkcp(){
    file_source="$(echo "$@" | cut -d ":" -f 1)"  # Parse the first part of each line in the variable "files".
    folder_dest="$(echo "$@" | cut -d ":" -f 2)"  # Parse the second part of each line in the variable "files".

    # Format everything and add it to the database.
    # Format : file_permission ; file_group ; file_path ; folder_permission ; folder_group ; folder_path ; backup_file
    echo "$(stat -c "%a;%U:%G;%n" "$file_source");$(stat -c "%a;%U:%G;%n" "$(dirname "$file_source")");$folder_dest$(basename "$file_source")" >> $database

    # Create destination folder.
    if [[ ! -e $folder_dest ]]; then
        mkdir "$folder_dest" -m 755 -p
        chown "$SUDO_USER":"$SUDO_USER" "$folder_dest"
        if (($? != 0)); then
            echo -e "\n\x1B[31mAn error occurred will chmod $folder_dest as $SUDO_USER\x1B[0m"
            return 1
        fi
    fi

    # Copy each file if it is different and newer preserving its attributes.
    cp -uv --preserve=all "$file_source" "$folder_dest"
    if (($? != 0)); then
        echo -e "\n\x1B[31mAn error occurred will copying $file_source to $folder_dest\x1B[0m"
        return 1
    fi

    return 0
}


##################################################
# DATABASE INIT
##################################################
echo -e "\n\x1B[34mResetting permission database\x1B[0m"
echo -n "" > $database
chmod 664 $database
chown "$SUDO_USER":"$SUDO_USER" $database
top_backup_folder=$(echo $backup_folder | cut -d'/' -f 1)
if [ -d "$top_backup_folder" ]; then
    rm -r "${top_backup_folder:?}/"
fi

##################################################
# COPY
##################################################
echo -e "\n\x1B[34mCopying files\x1B[0m"

for f in "${files[@]}"
do
    if mkcp "$f"; then
        continue
    else
        exit 1
    fi
done

echo -e "\n\x1B[34mCleaning\x1B[0m"
find "./$top_backup_folder" -type d -exec chmod 755 {} +
find "./$top_backup_folder" -type f -exec chmod 664 {} +
chown -R "$SUDO_USER":"$SUDO_USER" "${top_backup_folder:?}/"

echo -e "\n\x1B[32mDone\x1B[0m"
exit 0
