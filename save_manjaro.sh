#!/bin/bash

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

function prompt_username(){
    read -rp "name of the non-root user : " main_user
    if ! id -u "$main_user" >/dev/null 2>&1; then
		echo "User does not exist"
		prompt_username
	fi
}
prompt_username


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
    "/home/$main_user/.bashrc:$backup_folder/$main_user/"
    "/home/$main_user/.config/htop/htoprc:$backup_folder/$main_user/.config/htop/"
    "/home/$main_user/.config/kglobalshortcutsrc:$backup_folder/$main_user/.config/"
    "/home/$main_user/.gitconfig:$backup_folder/$main_user/"
    "/home/$main_user/.gnupg/gpg-agent.conf:$backup_folder/$main_user/.gnupg/"
    "/home/$main_user/.gnupg/public.key:$backup_folder/$main_user/.gnupg/"
    "/home/$main_user/.local/share/konsole/Custom.profile:$backup_folder/$main_user/.local/konsole/"
    "/home/$main_user/.nanorc:$backup_folder/$main_user/"
    "/home/$main_user/.p10k.zsh:$backup_folder/$main_user/"
    "/home/$main_user/.ssh/config:$backup_folder/$main_user/.ssh/"
    "/home/$main_user/.zshrc:$backup_folder/$main_user/"

    ########################### Git Hooks ###########################
    # Pre commit
    "/home/$main_user/.git-hooks/pre-commit:$backup_folder/$main_user/.git-hooks/"
    "/home/$main_user/.git-hooks/pre-commit.d/01.check-for-private-key.hook:$backup_folder/$main_user/.git-hooks/pre-commit.d/"
    "/home/$main_user/.git-hooks/pre-commit.d/02.check-for-env-files.hook:$backup_folder/$main_user/.git-hooks/pre-commit.d/"
    "/home/$main_user/.git-hooks/pre-commit.d/03.check-for-credentials.hook:$backup_folder/$main_user/.git-hooks/pre-commit.d/"
    "/home/$main_user/.git-hooks/pre-commit.d/04.remove-trailing-space.hook:$backup_folder/$main_user/.git-hooks/pre-commit.d/"
    "/home/$main_user/.git-hooks/pre-commit.d/05.fix-end-of-files.hook:$backup_folder/$main_user/.git-hooks/pre-commit.d/"
    "/home/$main_user/.git-hooks/pre-commit.d/06.format-go-files.hook:$backup_folder/$main_user/.git-hooks/pre-commit.d/"
    "/home/$main_user/.git-hooks/pre-commit.d/07.validate-json-files.hook:$backup_folder/$main_user/.git-hooks/pre-commit.d/"
    "/home/$main_user/.git-hooks/pre-commit.d/08.validate-xml-files.hook:$backup_folder/$main_user/.git-hooks/pre-commit.d/"
    # Commit msg
    "/home/$main_user/.git-hooks/commit-msg:$backup_folder/$main_user/.git-hooks/"
    "/home/$main_user/.git-hooks/commit-msg.d/01.check-message.hook:$backup_folder/$main_user/.git-hooks/commit-msg.d/"
    # Post update
    "/home/$main_user/.git-hooks/post-update:$backup_folder/$main_user/.git-hooks/"
    "/home/$main_user/.git-hooks/post-update.d/01.update-server-info.hook:$backup_folder/$main_user/.git-hooks/post-update.d/"

    ############################ System #############################
    "/etc/issue:$backup_folder/etc/"
    "/etc/pacman.conf:$backup_folder/etc/"
    "/etc/pam.d/system-auth:$backup_folder/etc/pam.d/"
    "/etc/sudoers.d/timeout:$backup_folder/etc/sudoers.d/"
    "/etc/sudoers.d/editor:$backup_folder/etc/sudoers.d/"
    "/etc/udev/rules.d/99-via.rules:$backup_folder/etc/udev/"

    ####################### Root config files #######################
    "/root/.bashrc:$backup_folder/root/"
    "/root/.config/htop/htoprc:$backup_folder/root/"
    "/root/.nanorc:$backup_folder/root/"
    "/root/.p10k.zsh:$backup_folder/root/"
    "/root/.zshrc:$backup_folder/root/"
)


##################################################
# FUNCTIONS
##################################################
function mkcp(){
    file_source="$(echo "$@" | cut -d ":" -f 1)"  # Parse the first part of each line in the variable "files".
    folder_dest="$(echo "$@" | cut -d ":" -f 2)"  # Parse the second part of each line in the variable "files".

    # Format everything and add it to the database.
    # Format : file_permission ; file_group ; file_path ; folder_permission ; folder_group ; folder_path ; backup_file
    echo "$(stat -c "%a;%U:%G;%n" "$file_source");$(stat -c "%a;%U:%G;%n" "$(dirname "$file_source")");$folder_dest$(basename "$file_source")" | sed "s/$main_user/main_user/g" >> $database

    # Create destination folder.
    if [[ ! -e $folder_dest ]]; then
        mkdir "$folder_dest" -m 755 -p
        chown "$main_user":"$main_user" "$folder_dest"
        if (($? != 0)); then
            echo -e "\n\x1B[31mAn error occurred will chmod $folder_dest\x1B[0m"
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
chown "$main_user":"$main_user" $database
rm -r "${backup_folder:?}/"

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
top_backup_folder=$(echo $backup_folder | cut -d'/' -f 1)
find ./$top_backup_folder -type d -exec chmod 755 {} +
find ./$top_backup_folder -type f -exec chmod 664 {} +
chown -R "$main_user":"$main_user" ./$top_backup_folder/

echo -e "\n\x1B[32mDone\x1B[0m"
exit 0
