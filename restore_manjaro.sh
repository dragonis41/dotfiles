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


##################################################
# FUNCTIONS
##################################################
function install_packages(){
    echo -e "\n\x1B[34mUpdating package list and system packages\x1B[0m"
    pacman-mirrors -c ch,de,fr,nl
    pacman -Syyu --noconfirm
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Base packages] An error occurred will updating the system\x1B[0m"
        exit 1
    fi
    echo -e "\n\x1B[34mInstalling base packages (It may take a long time)\x1B[0m"
    pacman --noconfirm -S yay nano gnupg xclip git base base-devel go pcsc-tools ccid gtk2 intel-ucode
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Base packages] An error occurred will installing packages with pacman\x1B[0m"
        exit 1
    fi
    sudo -H -u "$SUDO_USER" bash -c 'yay --noconfirm --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop -S bind linux69 linux69-headers mkinitcpio-firmware autojump fprintd fd jq fx dialog gum noto-fonts-emoji mtr nano-syntax-highlighting partitionmanager'
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Base packages] An error occurred will installing packages with yay\x1B[0m"
        exit 1
    fi
}

function install_extra_packages(){
    echo -e "\n\x1B[34mUpdating package list and system packages\x1B[0m"
    pacman -Syyu --noconfirm
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Extra packages] An error occurred will updating the system\x1B[0m"
        exit 1
    fi
    echo -e "\n\x1B[34mInstalling extra packages (It may take a long time)\x1B[0m"
    pacman -S yay --noconfirm
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Extra packages] An error occurred will installing packages with pacman\x1B[0m"
        exit 1
    fi
    sudo -H -u "$SUDO_USER" bash -c 'yay --noconfirm --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop -S google-chrome jetbrains-toolbox burpsuite filezilla mattermost-desktop notepadqq postman-bin thunderbird vlc realvnc-vnc-viewer realvnc-vnc-server hopenpgp-tools yubikey-personalization docker docker-compose docker-machine lazydocker gpart mtools gparted visidata'
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Extra packages] An error occurred will installing packages with yay\x1B[0m"
        exit 1
    fi
    systemctl enable docker.service
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Extra packages] An error occurred will enabling docker.service\x1B[0m"
        exit 1
    fi
    usermod -aG docker "$SUDO_USER"
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Extra packages] An error occurred will usermod docker group for $SUDO_USER\x1B[0m"
        exit 1
    fi
    systemctl enable vncserver-x11-serviced.service
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Extra packages] An error occurred will enabling vncserver-x11-serviced.service\x1B[0m"
        exit 1
    fi
}

function install_ohmyzsh(){
    echo -e "\x1B[34mInstalling oh-my-zsh with plugins\x1B[0m"
    pacman -S git --noconfirm

    # Installing for root
    if [ -d "/root/.oh-my-zsh" ]; then
        rm -r /root/.oh-my-zsh/
    fi
    sudo -H -u root bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    sudo -H -u root bash -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
    sudo -H -u root bash -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
    sudo -H -u root bash -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/themes/powerlevel10k'

    # Installing for user
    if [ -d "/home/$SUDO_USER/.oh-my-zsh" ]; then
        rm -r "/home/$SUDO_USER/.oh-my-zsh/"
    fi
    sudo -H -u "$SUDO_USER" bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    sudo -H -u "$SUDO_USER" bash -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
    sudo -H -u "$SUDO_USER" bash -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
    sudo -H -u "$SUDO_USER" bash -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'
}

function configure_yubikey(){
    systemctl enable --now pcscd.socket
    if (($? != 0)); then
        echo -e "\n\x1B[31m[Yubikey] An error occurred will enabling pcscd.socket\x1B[0m"
        exit 1
    fi

    echo ""
    read -rp "Insert the Yubikey and press enter to continue" yn
    case $yn in
        * ) echo -e "\n\x1B[34mConfiguring Yubikey\x1B[0m";;
    esac

    sudo -H -u "$SUDO_USER" bash -c 'gpg --import $HOME/.gnupg/public.key'
}

function restore_config(){
    echo -e "\n\x1B[34mRestoring configuration files\x1B[0m"
    while read -r line
    do
        folder_path="$(echo "$line" | cut -d ";" -f6)"

        # Restore files if
        # - The folder is different than "/etc/pam.d"
        # - The folder is "/etc/pam.d" and $var_install_fingerprint is true
        if [ "$folder_path" == "/etc/pam.d" ]; then
            if [ "$var_install_fingerprint" == "true" ]; then
                copyfile "$line"
            fi
        else
            copyfile "$line"
        fi
    done < $database
}

function copyfile(){
    line=$1

    # Format : file_permission ; file_group ; file_path ; folder_permission ; folder_group ; folder_path ; backup_file
    file_permission="$(echo "$line" | cut -d ";" -f1)"
    file_group="$(echo "$line" | cut -d ";" -f2)"
    file_path="$(echo "$line" | cut -d ";" -f3)"
    folder_permission="$(echo "$line" | cut -d ";" -f4)"
    folder_group="$(echo "$line" | cut -d ";" -f5)"
    folder_path="$(echo "$line" | cut -d ";" -f6)"
    backup_file="$(echo "$line" | cut -d ";" -f7)"

    # create original folder with right permissions.
    if [[ ! -e $folder_path ]]; then
        mkdir "$folder_path" -m "$folder_permission" -p
        if (($? != 0)); then
            echo -e "\n\x1B[31m[copyfile()] An error occurred will creating $folder_path folder\x1B[0m"
            exit 1
        fi
        chown -R "$folder_group" "$folder_path"
        if (($? != 0)); then
            echo -e "\n\x1B[31m[copyfile()] An error occurred will chown $folder_path with $folder_group\x1B[0m"
            exit 1
        fi
    fi

    # Copy each file by preserving its attributes.
    cp -v --preserve=all "$backup_file" "$file_path"
    if (($? != 0)); then
        echo -e "\n\x1B[31m[copyfile()] An error occurred will copying $backup_file to $file_path\x1B[0m"
        exit 1
    fi

    # Set the right permission.
    chmod "$file_permission" "$file_path"
    if (($? != 0)); then
        echo -e "\n\x1B[31m[copyfile()] An error occurred will chmod $file_path with $file_permission\x1B[0m"
        exit 1
    fi

    # Set the right group.
    chown "$file_group" "$file_path"
    if (($? != 0)); then
        echo -e "\n\x1B[31m[copyfile()] An error occurred will chown $file_path with $file_group\x1B[0m"
        exit 1
    fi
}

function display_end_message(){
    if ($var_install_fingerprint); then
        echo -e "\n\x1B[34mEnd configuration : Fingerprint\x1B[0m"
        function end_prompt_fingerprint(){
            read -rp "Do you want to register a fingerprint ? [yn]  " yn
            case $yn in
                [Yy]* )
                    sudo -H -u "$SUDO_USER" bash -c 'fprintd-enroll '"$SUDO_USER"
                    if (($? != 0)); then
                        echo -e "\n\x1B[31mAn error occurred will enrolling fingerprint\x1B[0m"
                        exit 1
                    fi
                    sudo -H -u "$SUDO_USER" bash -c 'fprintd-verify'
                    if (($? != 0)); then
                        echo -e "\n\x1B[31mAn error occurred will verifying fingerprint enroll\x1B[0m"
                        exit 1
                    fi
                ;;
                [Nn]* )
                    echo -e "\nIf there is no fingerprint registered, execute the following command :"
                    echo -e "\x1B[33mfprintd-enroll \$(whoami)\x1B[0m"
                    echo -e "\x1B[33mfprintd-verify\x1B[0m"
                ;;
                * ) echo "Please answer yes or no."; end_prompt_fingerprint;;
            esac
        }
        end_prompt_fingerprint
    fi

    if ($var_configure_yubikey); then
        echo -e "\n\x1B[34mEnd configuration : Fingerprint\x1B[0m"
        echo "To continue the configuration of the Yubikey, execute :"
        echo -e "\x1B[33mgpg --edit-card\x1B[0m"
        echo "Copy the secret key ID, then"
        echo -e "\x1B[33mgpg --edit-key KEYID\x1B[0m"
        echo -e "\x1B[33mtrust\x1B[0m"
        echo -e "\x1B[33m5\x1B[0m"
        echo -e "\x1B[33mquit\x1B[0m"
        echo "Then, reboot."
    fi

    echo -e "\n\x1B[33m⚠️ Please, check that you are using x11, VNC Server won't start on Wayland ⚠️\n\n\x1B[34mDone\x1B[0m\n\n"
}


##################################################
# PROGRAM
##################################################
# Variables for choices prompt.
var_install_packages=false
var_install_extra=false
var_install_ohmyzsh=false
var_install_fingerprint=false
var_configure_yubikey=false

function prompt_packages(){
    read -rp "Install base packages ? [yn] " yn
    case $yn in
        [Yy]* ) var_install_packages=true;;
        [Nn]* ) var_install_packages=false;;
        * ) echo "Please answer yes or no."; prompt_packages;;
    esac
}
prompt_packages

function prompt_extra_packages(){
    read -rp "Install extra packages ? [yn] " yn
    case $yn in
        [Yy]* ) var_install_extra=true;;
        [Nn]* ) var_install_extra=false;;
        * ) echo "Please answer yes or no."; prompt_extra_packages;;
    esac
}
prompt_extra_packages

function prompt_ohmyzsh(){
    read -rp "Install Oh My Zsh with plugins ? Warning : It will delete current installation [yn] " yn
    case $yn in
        [Yy]* ) var_install_ohmyzsh=true;;
        [Nn]* ) var_install_ohmyzsh=false;;
        * ) echo "Please answer yes or no."; prompt_ohmyzsh;;
    esac
}
prompt_ohmyzsh

function prompt_fingerprint(){
    read -rp "Install fingerprint PAM config ? [yn] " yn
    case $yn in
        [Yy]* ) var_install_fingerprint=true;;
        [Nn]* ) var_install_fingerprint=false;;
        * ) echo "Please answer yes or no."; prompt_fingerprint;;
    esac
}
prompt_fingerprint

function prompt_yubikey(){
    read -rp "Configure the Yubikey ? [yn] " yn
    case $yn in
        [Yy]* ) var_configure_yubikey=true;;
        [Nn]* ) var_configure_yubikey=false;;
        * ) echo "Please answer yes or no."; prompt_yubikey;;
    esac
}
prompt_yubikey


if ($var_install_packages); then
    install_packages
fi
if ($var_install_extra); then
    install_extra_packages
fi
if ($var_install_ohmyzsh); then
    install_ohmyzsh
fi

if ! restore_config; then
    exit 1
fi
if ($var_configure_yubikey); then
    configure_yubikey
fi

display_end_message

echo -e "\n\x1B[32mDone\x1B[0m"
exit 0
