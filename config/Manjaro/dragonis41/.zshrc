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
zbell_ignore=($EDITOR $PAGER htop man nano top)
zbell_use_notify_send=true
# Prevent compinit from putting config, cache and dump file in $HOME
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

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


## ZSH OPTIONS
# History
HISTFILE="$HOME/.zhistory"
HISTSIZE=10000000
SAVEHIST=10000000
unsetopt APPEND_HISTORY # When set, zsh sessions will append their history list to the history file, rather than replace it. Thus, multiple parallel zsh sessions will all have the new entries from their history lists added to the history file, in the order that they exit. The file will still be periodically re-written to trim it when the number of lines grows 20% beyond the value specified by $SAVEHIST (see also the HIST_SAVE_BY_COPY option).
setopt EXTENDED_HISTORY # When set, Save each command’s beginning timestamp (in seconds since the epoch) and the duration (in seconds) to the history file. The format of this prefixed data is: ‘: <beginning time>:<elapsed seconds>;<command>’.
unsetopt HIST_EXPIRE_DUPS_FIRST # If the internal history needs to be trimmed to add the current command line, setting this option will cause the oldest history event that has a duplicate to be lost before losing a unique event from the list. You should be sure to set the value of HISTSIZE to a larger number than SAVEHIST in order to give you some room for the duplicated events, otherwise this option will behave just like HIST_IGNORE_ALL_DUPS once the history fills up with unique events.
unsetopt HIST_FIND_NO_DUPS # When searching for history entries in the line editor, do not display duplicates of a line previously found, even if the duplicates are not contiguous.
unsetopt HIST_IGNORE_ALL_DUPS # If a new command line being added to the history list duplicates an older one, the older command is removed from the list (even if it is not the previous event).
setopt HIST_IGNORE_DUPS # Do not enter command lines into the history list if they are duplicates of the previous event.
setopt HIST_IGNORE_SPACE # Remove command lines from the history list when the first character on the line is a space, or when one of the expanded aliases contains a leading space. Only normal aliases (not global or suffix aliases) have this behaviour. Note that the command lingers in the internal history until the next command is entered before it vanishes, allowing you to briefly reuse or edit the line. If you want to make it vanish right away without entering another command, type a space and press return.
setopt HIST_NO_STORE # Remove the history (fc -l) command from the history list when invoked. Note that the command lingers in the internal history until the next command is entered before it vanishes, allowing you to briefly reuse or edit the line.
setopt HIST_REDUCE_BLANKS # Remove superfluous blanks from each command line being added to the history list.
setopt HIST_SAVE_BY_COPY # When the history file is re-written, we normally write out a copy of the file named $HISTFILE.new and then rename it over the old one. However, if this option is unset, we instead truncate the old history file and write out the new version in-place. If one of the history-appending options is enabled, this option only has an effect when the enlarged history file needs to be re-written to trim it down to size. Disable this only if you have special needs, as doing so makes it possible to lose history entries if zsh gets interrupted during the save.
unsetopt HIST_SAVE_NO_DUPS # When writing out the history file, older commands that duplicate newer ones are omitted.
unsetopt INC_APPEND_HISTORY # This option works like APPEND_HISTORY except that new history lines are added to the $HISTFILE incrementally (as soon as they are entered), rather than waiting until the shell exits. The file will still be periodically re-written to trim it when the number of lines grows 20% beyond the value specified by $SAVEHIST (see also the HIST_SAVE_BY_COPY option).
unsetopt INC_APPEND_HISTORY_TIME # This option is a variant of INC_APPEND_HISTORY in which, where possible, the history entry is written out to the file after the command is finished, so that the time taken by the command is recorded correctly in the history file in EXTENDED_HISTORY format. This means that the history entry will not be available immediately from other instances of the shell that are using the same history file. This option is only useful if INC_APPEND_HISTORY and SHARE_HISTORY are turned off. The three options should be considered mutually exclusive.
setopt SHARE_HISTORY # This option both imports new commands from the history file, and also causes your typed commands to be appended to the history file (the latter is like specifying INC_APPEND_HISTORY, which should be turned off if this option is in effect). The history lines are also output with timestamps ala EXTENDED_HISTORY (which makes it easier to find the spot where we left off reading the file after it gets re-written). By default, history movement commands visit the imported lines as well as the local lines, but you can toggle this on and off with the set-local-history zle binding. It is also possible to create a zle widget that will make some commands ignore imported commands, and some include them. If you find that you want more control over when commands get imported, you may wish to turn SHARE_HISTORY off, INC_APPEND_HISTORY or INC_APPEND_HISTORY_TIME (see above) on, and then manually import commands whenever you need them using ‘fc -RI’.


# Alias
alias ccopy='xclip -sel clip <'
alias cls='clear'
alias dcd='docker compose down --remove-orphans --rmi all --volumes'
alias dcu='docker compose up -d --always-recreate-deps --force-recreate --build'
alias gc='git commit -S -m'
alias gfp='git fetch && git pull'
alias gh='git log --oneline | gum filter | cut -d" " -f1 | xargs -I {} sh -c "echo -n {} | xclip -sel clip"'
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
alias pager='gum pager <'
alias reboot-bios='sudo systemctl reboot --firmware-setup'
alias restart-network='sudo systemctl restart NetworkManager.service'
alias update='sudo pacman-mirrors -c ch,de,fr,nl; yay -Syyu; omz update; git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull'
alias yay='yay --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop'

# Fonctions
chpwd() { ls -laF --group-directories-first --color=auto }  # ZSH function. Show the content of the folder we just cd into.
gpmr() {
    # Ensure target branch is provided
    if [ -z "$1" ]
    then
        echo "Please provide a target branch name."
        return 1
    fi

    TARGET_BRANCH=$1

    # Git push with options to automatically create a merge request
    git push origin HEAD -o merge_request.create -o merge_request.target=$TARGET_BRANCH
}
mk() { mkdir -p -- "$1" && touch -- "$1"/"$2" && cd -- "$1" }  # Create as many folder and subfolder as wanted.
search() { find -L . -name "*$**" }  # Search for a specific file name recursively.
searchcontent() { fd --type f --exec grep -H "$*" --color=always | sed -r "s/([^:]*):/\x1B[34m\1\x1B[0m:/" } # Search for a string in all files recursively.
ghooks() {  # TUI to de/activate git hooks
  # Define the directories
  local -a directories=("$HOME/.git-hooks/pre-commit.d" "$HOME/.git-hooks/commit-msg.d" "$HOME/.git-hooks/post-update.d")

  # Create an array to hold the files
  local -a elements=()
  local -a elements_selected=()

  # Loop through each directory and each file in each directory
  for directory in "${directories[@]}"; do
    for file in "$directory"/*; do
      # Add the file to the list
      elements+=("$file")
      # Check if the file is executable
      if [[ -x "$file" ]]; then
        elements_selected+=("$file")  # If it is, add it to the selected array
      fi
    done
  done

  # Use gum to display a selectable list
  local result
  result=$(gum choose --no-limit --selected=$elements_selected $elements)
  # Check the exit status of dialog
  local dialog_status=$?

  # If the status is 1, the user clicked "Cancel", so exit the function
  if [[ $dialog_status -ne 0 ]]; then
    echo -e "\x1B[33mCanceled\x1B[0m"
    return 1
  fi

  # Reset permissions
  for directory in "${directories[@]}"; do
    chmod -x "$directory"/*
  done

  if [[ -z "$result" ]]; then
    return 0
  fi

  # Convert result string to an array
  local -a result_array=("${(@f)result}")

  # Make executable every selected hook
  for item in "${result_array[@]}"; do
    chmod +x "$item"
  done


  return 0
}
