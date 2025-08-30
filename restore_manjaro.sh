#!/bin/bash

##################################################
# VARIABLES
##################################################
# Name of the database where permissions, owners and paths are stored.
database="permissions_manjaro.db"
# Path of files used for Nvidia configuration.
# If there is no Nvidia card, we need to exclude thoses files or the graphical environnement will not start.
nvidia_config_files=(
    "/etc/optimus-manager/optimus-manager.conf"
    "/etc/X11/xorg.conf.d/10-optimus-manager.conf"
    "/etc/sddm.conf"
    "/etc/modprobe.d/nvidia-installer-disable-nouveau.conf"
    "/usr/lib/modprobe.d/nvidia-installer-disable-nouveau.conf"
)


###################################################################################################################################
################################################## DO NOT MODIFY BELOW THIS LINE ##################################################
###################################################################################################################################


##################################################
# FUNCTIONS
##################################################
function install_packages(){
    display_step "Updating package list and system packages (It may take a long time)"
    pacman-mirrors -c ch,de,fr,nl
    if ! pacman -Syyu --noconfirm
    then
        display_error "[Base packages] An error occurred will updating the system"
    fi
    display_step "Installing base packages [step 1/2] (It may take a long time)"
    if ! pacman --noconfirm -S yay nano gnupg xclip git base base-devel go pcsc-tools ccid gtk2 intel-ucode
    then
        display_error "[Base packages] An error occurred will installing packages with pacman"
    fi
    display_step "Installing base packages [step 2/2] (It may take a long time)"
    if ! sudo -H -u "$SUDO_USER" bash -c 'yay --noconfirm --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop -S bind linux616 linux616-headers mkinitcpio-firmware autojump fprintd fd jq fx dialog gum noto-fonts-emoji mtr nano-syntax-highlighting partitionmanager extra/libinput-gestures extra/gestures throttled'
    then
        display_error "[Base packages] An error occurred will installing packages with yay"
    fi
    if ! usermod -aG input "$SUDO_USER"
    then
        display_error "[Base packages] An error occurred will usermod input group for $SUDO_USER$"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
    if [ "$var_install_nvidia" == "true" ]; then
        display_step "Installing Nvidia packages (It may take a long time)"
        if ! sudo -H -u "$SUDO_USER" bash -c 'yay --noconfirm --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop -S linux616-nvidia optimus-manager extra/bbswitch-dkms acpi_call nvtop libva-nvidia-driver --overwrite'
        then
            display_error "[Base packages] An error occurred will installing packages with yay"
        fi
    fi
}

function install_extra_packages(){
    display_step "Updating package list and system packages (It may take a long time)"
    if ! pacman -Syyu --noconfirm
    then
        display_error "[Extra packages] An error occurred will updating the system"
    fi
    display_step "Installing extra packages [step 1/2]"
    if ! pacman -S yay --noconfirm
    then
        display_error "[Extra packages] An error occurred will installing packages with pacman"
    fi
    display_step "Installing extra packages [step 2/2] (It may take a long time)"
    if ! sudo -H -u "$SUDO_USER" bash -c 'yay --noconfirm --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop -S brave-browser jetbrains-toolbox mattermost-desktop thunderbird vlc hopenpgp-tools yubikey-personalization docker docker-compose docker-machine lazydocker gpart mtools gparted visidata'
    then
        display_error "[Extra packages] An error occurred will installing packages with yay"
    fi
    display_step "[Extra packages] Enabling docker.service"
    if ! systemctl enable docker.service
    then
        display_error "[Extra packages] An error occurred will enabling docker.service"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
    display_step "[Extra packages] Adding user ${SUDO_USER} to docker group"
    if ! usermod -aG docker "$SUDO_USER"
    then
        display_error "[Extra packages] An error occurred will usermod docker group for $SUDO_USER$"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
}

function install_qemu(){
    display_step "Installing Virt-manager libvirt and Qemu [step 1/2]"
    if ! pacman -S yay --noconfirm
    then
        display_error "[Virt-manager - Qemu] An error occurred will installing packages with pacman"
    fi
    display_step "Installing Virt-manager libvirt and Qemu [step 2/2] (It may take a long time)"
    if ! sudo -H -u "$SUDO_USER" bash -c 'yay --noconfirm --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop -S qemu virt-manager libvirt'
    then
        display_error "[Extra packages] An error occurred will installing packages with yay"
    fi
    display_step "[Virt-manager - Qemu] Adding user ${SUDO_USER} to libvirt group"
    if ! usermod -aG libvirt "$SUDO_USER"
    then
        display_error "[Virt-manager - Qemu] An error occurred will adding ${SUDO_USER} to libvirt group"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
    display_step "[Virt-manager - Qemu] Enabling virtlogd.socket"
    if ! systemctl enable --now virtlogd.socket
    then
        display_error "[Virt-manager - Qemu] An error occurred will enabling virtlogd.socket"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
    display_step "[Virt-manager - Qemu] Enabling virtqemud.socket"
    if ! systemctl enable --now virtqemud.socket
    then
        display_error "[Virt-manager - Qemu] An error occurred will enabling virtqemud.socket"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
    display_step "[Virt-manager - Qemu] Enabling libvirtd.service"
    if ! systemctl enable --now libvirtd.service
    then
        display_error "[Virt-manager - Qemu] An error occurred will enabling libvirtd.service"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
    display_step "[Virt-manager - Qemu] Setting user rights to libvirt-sock"
    if ! setfacl -m user:"${SUDO_USER}":rw /var/run/libvirt/libvirt-sock
    then
        display_error "[Virt-manager - Qemu] An error occurred will setting user rights to libvirt-sock"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
    display_step "[Virt-manager - Qemu] Defining default Qemu network"
    if ! virsh net-define /etc/libvirt/qemu/networks/default.xml
    then
        display_error "[Virt-manager - Qemu] An error occurred will defining default Qemu network"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
    display_step "[Virt-manager - Qemu] Setting autostart on default Qemu network"
    if ! virsh net-autostart default
    then
        display_error "[Virt-manager - Qemu] An error occurred will setting autostart on Qemu network"
    else
        echo -e "${green_color}ok${reset_color}"
    fi
}

function install_ohmyzsh(){
    display_step "Installing oh-my-zsh with plugins"
    pacman -S git --noconfirm

    # Installing for root
    display_step "[Oh My Zsh] Installing Oh My Zsh for root user (type 'exit' when you fallback into a shell)"
    if [ -d "/root/.oh-my-zsh" ]; then
        rm -r /root/.oh-my-zsh/
    fi
    sudo -H -u root bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    sudo -H -u root bash -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
    sudo -H -u root bash -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
    sudo -H -u root bash -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/themes/powerlevel10k'

    # Installing for user
    display_step "[Oh My Zsh] Installing Oh My Zsh for ${SUDO_USER} user (type 'exit' when you fallback into a shell)"
    if [ -d "/home/$SUDO_USER/.oh-my-zsh" ]; then
        rm -r "/home/$SUDO_USER/.oh-my-zsh/"
    fi
    sudo -H -u "$SUDO_USER" bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    sudo -H -u "$SUDO_USER" bash -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
    sudo -H -u "$SUDO_USER" bash -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
    sudo -H -u "$SUDO_USER" bash -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'
}

function configure_yubikey(){
    display_step "[Yubikey] Enabling pcscd.socket"
    if ! systemctl enable --now pcscd.socket
    then
        display_error "[Yubikey] An error occurred will enabling pcscd.socket"
    else
        echo -e "${green_color}ok${reset_color}"
    fi

    echo ""
    read -rp "Insert the Yubikey and press enter to continue" key_pressed
    case $key_pressed in
        * ) display_step "Configuring Yubikey";;
    esac

    if ! sudo -H -u "$SUDO_USER" bash -c 'gpg --import $HOME/.gnupg/public.key'
    then
        display_error "[Yubikey] An error occurred will importing new GPG key"
    fi
}

function restore_config(){
    display_step "Restoring configuration files"
    while read -r line
    do
        file_path="$(echo "$line" | cut -d ";" -f3)"
        folder_path="$(echo "$line" | cut -d ";" -f6)"

        # Restore files if
        # - The folder is different than "/etc/pam.d"
        # - The folder is "/etc/pam.d" and $var_install_fingerprint is true
        if [ "$folder_path" == "/etc/pam.d" ]; then
            if [ "$var_install_fingerprint" == "true" ]; then
                copyfile "$line"
            fi
        elif [[ ${nvidia_config_files[*]} =~ $file_path ]]; then
            if [ "$var_install_nvidia" == "true" ]; then
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
        # shellcheck disable=SC2174
        if ! mkdir "$folder_path" -m "$folder_permission" -p
        then
            display_error "[copyfile()] An error occurred will creating $folder_path folder"
        fi
        if ! chown -R "$folder_group" "$folder_path"
        then
            display_error "[copyfile()] An error occurred will chown $folder_path with $folder_group"
        fi
    fi

    # Copy each file by preserving its attributes.
    if ! cp -v --preserve=all "$backup_file" "$file_path"
    then
        display_error "[copyfile()] An error occurred will copying $backup_file to $file_path"
    fi

    # Set the right permission.
    if ! chmod "$file_permission" "$file_path"
    then
        display_error "[copyfile()] An error occurred will chmod $file_path with $file_permission"
    fi

    # Set the right group.
    if ! chown "$file_group" "$file_path"
    then
        display_error "[copyfile()] An error occurred will chown $file_path with $file_group"
    fi
}

function display_end_message(){
    if ($var_install_fingerprint); then
        display_step "End configuration : Fingerprint"
        function end_prompt_fingerprint(){
            read -rp "Do you want to register a fingerprint ? [yn]  " yn
            case $yn in
                [Yy]* )
                    display_step "[Fingerprint] Enrolling a new fingerprint"
                    if ! sudo -H -u "$SUDO_USER" bash -c 'fprintd-enroll '"$SUDO_USER"
                    then
                        display_error "An error occurred will enrolling fingerprint"
                    fi
                    display_step "[Fingerprint] Verifying the newly registered fingerprint"
                    if ! sudo -H -u "$SUDO_USER" bash -c 'fprintd-verify'
                    then
                        display_error "An error occurred will verifying fingerprint enroll"
                    fi
                ;;
                [Nn]* )
                    echo -e "\nIf there is no fingerprint registered, execute the following command :"
                    echo -e "${orange_color}fprintd-enroll \$(whoami)${reset_color}"
                    echo -e "${orange_color}fprintd-verify${reset_color}"
                ;;
                * ) echo "Please answer yes or no."; end_prompt_fingerprint;;
            esac
        }
        end_prompt_fingerprint
    fi

    if ($var_configure_yubikey); then
        display_step "End configuration : Fingerprint"
        echo "To continue the configuration of the Yubikey, execute :"
        echo -e "${orange_color}gpg --edit-card${reset_color}"
        echo "Copy the secret key ID, then"
        echo -e "${orange_color}gpg --edit-key KEYID${reset_color}"
        echo -e "${orange_color}trust${reset_color}"
        echo -e "${orange_color}5${reset_color}"
        echo -e "${orange_color}quit${reset_color}"
        echo "Then, reboot."
    fi
}

function display_step {
  echo -e "\n--------------------------------------------------------------------------------"
  echo -e "${blue_color}$1${reset_color}"
  echo -e "--------------------------------------------------------------------------------"
}

function display_error {
  echo -e "\n--------------------------------------------------------------------------------"
  echo -e "${red_background_color}$1${reset_background_color}"
  echo -e "--------------------------------------------------------------------------------\n"
  exit 1
}


##################################################
# INTERNAL VARIABLES
##################################################
# Variables for text color.
reset_color="\x1B[0m"
green_color="\x1B[32m"
orange_color="\x1B[33m"
blue_color="\x1B[34m"
reset_background_color="\x1B[49m"
red_background_color="\x1B[41m"
# Variables for choices prompt.
var_install_packages=false
var_install_extra=false
var_install_qemu=false
var_install_ohmyzsh=false
var_install_fingerprint=false
var_install_nvidia=false
var_configure_yubikey=false


##################################################
# PROGRAM
##################################################
if [ "$EUID" -ne 0 ] || [ "$SUDO_USER" = "" ]; then
    display_error "Please run as your current user with sudo but not as root"
fi

function prompt_restore(){
    echo -e "This script will restore files for user [$SUDO_USER], if the already backed up files do not match this username, you can break your system !"
    read -rp "Continue ? [yn] " yn
    case $yn in
        [Yy]* ) var_install_packages=true;;
        [Nn]* ) var_install_packages=false;;
        * ) echo "Please answer yes or no."; prompt_restore;;
    esac
}
prompt_restore

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

function prompt_qemu(){
    read -rp "Install Virt-manager with Qemu ? [yn] " yn
    case $yn in
        [Yy]* ) var_install_qemu=true;;
        [Nn]* ) var_install_qemu=false;;
        * ) echo "Please answer yes or no."; prompt_qemu;;
    esac
}
prompt_qemu

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

function prompt_nvidia(){
    read -rp "Install Nvidia configuration files ? [yn] " yn
    case $yn in
        [Yy]* ) var_install_nvidia=true;;
        [Nn]* ) var_install_nvidia=false;;
        * ) echo "Please answer yes or no."; prompt_nvidia;;
    esac
}
prompt_nvidia

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
if ($var_install_qemu); then
    install_qemu
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

echo -e "\n${green_color}Done${reset_color}"
exit 0
