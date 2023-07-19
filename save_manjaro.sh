#!/bin/bash

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi


##################################################
# VARIABLES
##################################################
# Name of the database where permissions, owners and paths are stored.
database="permissions.db"
# Full path of files to save.
# Format: "source:dest".
files=(
    ####################### User config files #######################
    "/home/dragonis41/.gnupg/gpg-agent.conf:Manjaro/dragonis41/.gnupg/"
    "/home/dragonis41/.gnupg/public.key:Manjaro/dragonis41/.gnupg/"
    "/home/dragonis41/.bashrc:Manjaro/dragonis41/"
    "/home/dragonis41/.gitconfig:Manjaro/dragonis41/"
    "/home/dragonis41/.nanorc:Manjaro/dragonis41/"
    "/home/dragonis41/.p10k.zsh:Manjaro/dragonis41/"
    "/home/dragonis41/.zshrc:Manjaro/dragonis41/"
    "/home/dragonis41/.config/htop/htoprc:Manjaro/dragonis41/"

    ########################### Git Hooks ###########################
    # Pre commit
    "/home/dragonis41/.git-hooks/pre-commit:Manjaro/dragonis41/.git-hooks/"
    "/home/dragonis41/.git-hooks/pre-commit.d/01.check-for-private-key.hook:Manjaro/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/02.check-for-env-files.hook:Manjaro/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/03.check-for-credentials.hook:Manjaro/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/04.remove-trailing-space.hook:Manjaro/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/05.fix-end-of-files.hook:Manjaro/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/06.format-go-files.hook:Manjaro/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/07.validate-json-files.hook:Manjaro/dragonis41/.git-hooks/pre-commit.d/"
    "/home/dragonis41/.git-hooks/pre-commit.d/08.validate-xml-files.hook:Manjaro/dragonis41/.git-hooks/pre-commit.d/"
    # Commit msg
    "/home/dragonis41/.git-hooks/commit-msg:Manjaro/dragonis41/.git-hooks/"
    "/home/dragonis41/.git-hooks/commit-msg.d/01.check-message.hook:Manjaro/dragonis41/.git-hooks/commit-msg.d/"
    # Post update
    "/home/dragonis41/.git-hooks/post-update:Manjaro/dragonis41/.git-hooks/"
    "/home/dragonis41/.git-hooks/post-update.d/01.update-server-info.hook:Manjaro/dragonis41/.git-hooks/post-update.d/"

    ############################ System #############################
    "/etc/issue:Manjaro/etc/"
    "/etc/pacman.conf:Manjaro/etc/"
    "/etc/pam.d/system-auth:Manjaro/etc/"

    ####################### Root config files #######################
    "/root/.bashrc:Manjaro/root/"
    "/root/.nanorc:Manjaro/root/"
    "/root/.p10k.zsh:Manjaro/root/"
    "/root/.zshrc:Manjaro/root/"
    "/home/dragonis41/.config/htop/htoprc:Manjaro/root/"
)


##################################################
# FUNCTIONS
##################################################
function mkcp(){
    file_source="$(echo "$@" | cut -d ":" -f 1)"  # Parse the first part of each line in the variable "files".
    folder_dest="$(echo "$@" | cut -d ":" -f 2)"  # Parse the second part of each line in the variable "files".

    # Format everything and add it to the database.
    # Format : file_permission ; file_group ; file_path ; folder_permission ; folder_group ; folder_path ; backup_file
    echo "$(stat -c "%a;%U:%G;%n" "$file_source");$(stat -c "%a;%U:%G;%n" $(dirname $file_source));$folder_dest$(basename $file_source)" >> $database

    # Create destination folder.
    if [[ ! -e $folder_dest ]]; then
        mkdir "$folder_dest" -m 755 -p
        chown dragonis41:dragonis41 "$folder_dest"
        if (($? != 0)); then
            echo -e "\n\x1B[31mAn error occured will chmod $folder_dest\x1B[0m"
            return 1
        fi
    fi

    # Copy each file if it is different and newer preserving its attributes.
    cp -uv --preserve=all "$file_source" "$folder_dest"
    if (($? != 0)); then
        echo -e "\n\x1B[31mAn error occured will copying $file_source to $folder_dest\x1B[0m"
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
chown dragonis41:dragonis41 $database
rm -r Manjaro/

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
find ./Manjaro -type d -exec chmod 755 {} +
find ./Manjaro -type f -exec chmod 664 {} +
chown -R dragonis41:dragonis41 ./Manjaro/

echo -e "\n\x1B[32mDone\x1B[0m"
exit 0
