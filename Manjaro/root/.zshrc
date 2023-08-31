# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Define if the completion is case-sensitive.
CASE_SENSITIVE="false"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    autojump # This plugin loads the autojump navigation tool.
    colored-man-pages # This plugin adds colors to man pages.
    extract # This plugin defines a function called `extract` that extracts the archive file you pass it, and it supports a wide variety of archive filetypes
    git # The git plugin provides many aliases and a few useful functions.
    gpg-agent # Enable gpg-agent if it's not running.
    history # Provides a couple of convenient aliases for using the `history` command to examine your command line history.
    kate # This plugin adds aliases for the Kate editor.
    nmap # Adds some useful aliases for Nmap similar to the profiles in zenmap.
    sudo # Easily prefix your current or previous commands with `sudo` by pressing 'esc' twice.
    web-search # This plugin adds aliases for searching with Google, Wiki, Bing, YouTube and other popular services.
    zbell # This plugin prints a bell character when a command finishes if it has been running for longer than a specified duration.
    zsh-syntax-highlighting # This package provides syntax highlighting for the shell zsh.
    zsh-autosuggestions # It suggests commands as you type based on history and completions.
)

# Exports
# Options for GPG and SSH agents with Yubikey.
export PATH=${PATH}:`go env GOPATH`/bin
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
# Options for Zbell oh-my-zsh plugin.
zbell_duration=30
zbell_ignore=($EDITOR $PAGER gdiff htop man nano top)
zbell_use_notify_send=true

# Load Oh My Zsh plugins.
source $ZSH/oh-my-zsh.sh

# User configuration

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Use powerline
USE_POWERLINE="true"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Alias
alias ccopy='xclip -sel clip <'
alias cls='clear'
alias dcd='docker compose down --remove-orphans --rmi all --volumes'
alias dcu='docker compose up -d --always-recreate-deps --force-recreate --build'
alias gc='git commit -S -m'
alias gfp='git fetch && git pull'
alias gtree='git log --graph --oneline --all'
alias gtree+="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%n' --abbrev-commit --date=relative --branches --all"
alias go-get='ssh-add -L && export GOPRIVATE=gitlab.dev.petit.ninja && go get -v -x '
#alias go-get='eval $(ssh-agent -s) && ssh-add && export GOPRIVATE=gitlab.dev.petit.ninja && go get -v -x '
alias gp='git push'
alias gpg-yubi='gpg-connect-agent "scd serialno" "learn --force" /bye'
alias history="omz_history -i | awk '{ printf \"\033[1;32m%s  \033[1;33m%s \033[1;33m%s \033[0m\", \$1, \$2, \$3; for(i=4; i<=NF; i++) printf \" \033[1;34m%s\033[0m\", \$i; printf \"\n\" }'"
alias ip='ip -color'
alias l='ls -laF --group-directories-first --color=auto'
alias lzd='lazydocker'
alias restart-bios='sudo systemctl reboot --firmware-setup'
alias restart-network='sudo systemctl restart NetworkManager.service'
alias update='yay -Syyu && git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull'
alias yay='yay --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop'


# Fonctions
chpwd() { ls -laF --group-directories-first --color=auto }  # ZSH function. Show the content of the folder we just cd into.
mk() { mkdir -p -- "$1" && touch -- "$1"/"$2" && cd -- "$1" }  # Create as many folder and subfolder as wanted.
search() { find -L . -name "*$**" }  # Search for a specific file name recursively.
searchcontent() { fd --type f --exec grep "$*" --color=always } # Search for a string in all files recursively.
get_cpu_temp() { CEL=$'\xc2\xb0C'; temp=$(cat /sys/devices/virtual/thermal/thermal_zone10/temp); temp=`expr $temp / 1000`; echo $temp$CEL; }  # Get the temperature of the CPU package for the XPS 9315.
git-hooks() {  # TUI to de/activate git hooks
  # Define the directories
  local -a directories=("$HOME/.git-hooks/pre-commit.d" "$HOME/.git-hooks/commit-msg.d" "$HOME/.git-hooks/post-update.d")

  # Create an array to hold the files and their permissions
  local -a elements=()

  # Loop through each directory and each file in each directory
  for directory in "${directories[@]}"; do
    for file in "$directory"/*; do
      # Check if the file is executable
      if [[ -x "$file" ]]; then
        elements+=("$file" "activated" "ON")  # If it is, add it to the array with a ON state
      else
        elements+=("$file" "deactivated" "OFF")  # If it isn't, add it to the array with a OFF state
      fi
    done
  done

  # Get terminal dimensions
  local height=$(tput lines)
  local width=$(tput cols)

  # Use dialog to display a selectable list
  local result
  result=$(dialog --checklist "Activated hooks :" $((height-10)) $((width/3*2)) $((height/3*2-5)) "${elements[@]}" 3>&1 1>&2 2>&3 3>&-)
  # Check the exit status of dialog
  local dialog_status=$?

  clear

  # If the status is 1, the user clicked "Cancel", so exit the function
  if [[ $dialog_status -eq 1 ]]; then
    echo -e "\x1B[33mCanceled\x1B[0m"
    return
  fi

  # Reset permissions
  for directory in "${directories[@]}"; do
    chmod -x "$directory"/*
  done

  # Convert result string to an array
  local -a result_array=("${(@s/ /)result}")

  # Make executable every selected hook
  for item in "${result_array[@]}"; do
    chmod +x "$item"
  done

  echo -e "\x1B[32mDone\x1B[0m"
}
