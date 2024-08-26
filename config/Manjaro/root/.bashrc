#
# ~/.bashrc
#

[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

xhost +local:root > /dev/null 2>&1

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


# Exports
# Options for GPG and SSH agents with Yubikey.
export PATH=${PATH}:`go env GOPATH`/bin
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent


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
alias ip='ip -color'
alias l='ls -laF --group-directories-first --color=auto'
alias lzd='lazydocker'
alias pager='gum pager <'
alias reboot-bios='sudo systemctl reboot --firmware-setup'
alias restart-network='sudo systemctl restart NetworkManager.service'
alias update='sudo pacman-mirrors -c ch,de,fr,nl; yay -Syyu'
alias yay='yay --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop'


# Fonctions
mk() {
	mkdir -p -- "$1" && touch -- "$1"/"$2" && cd -- "$1" && ls -laF
}
gpmr() {
    # Ensure target branch is provided
    if [ -z "$1" ]
    then
        echo "Please provide a target branch name."
        return 1
    fi

    # Variables
    TARGET_BRANCH=$1

    # Git push with options to automatically create a merge request
    git push origin HEAD -o merge_request.create -o merge_request.target=$TARGET_BRANCH
}
search() {
	find -L . -name "*$**"
}
searchcontent() {
	fd --type f --exec grep -H "$*" --color=always | sed -r "s/([^:]*):/\x1B[34m\1\x1B[0m:/"
}
ghooks() {  # TUI to de/activate git hooks
  # Define the directories
  local directories=("$HOME/.git-hooks/pre-commit.d" "$HOME/.git-hooks/commit-msg.d" "$HOME/.git-hooks/post-update.d")

  # Create an array to hold the files
  local elements=()

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
  local result_array
  IFS=' ' read -ra result_array <<< "$result"

  # Make executable every selected hook
  for item in "${result_array[@]}"; do
    chmod +x "$item"
  done

  echo -e "\x1B[32mDone\x1B[0m"
}
gchelp() {
  echo -e "-------------------------------------------------------------------------------"
  echo -e "The format is : \x1B[1m\x1B[3mtype(scope): subject\x1B[0m"
  echo -e "Types :"
  echo -e " * \x1B[93mbuild\x1B[0m: Change in build configuration, dev tools, external dependencies, or other changes that don't affect the user."
  echo -e " * \x1B[93mBREAKING CHANGE\x1B[0m: Indicates that the change affects the public API, usually the removal or major modification of a feature."
  echo -e " * \x1B[93mchore\x1B[0m: Technical or preventive maintenance that is not related to functionality and does not impact the user. For example, the release of a new version or the regeneration of generated code can be considered as chores."
  echo -e " * \x1B[93mci\x1B[0m: Change related to continuous integration or the deployment environment."
  echo -e " * \x1B[93mdeprecate\x1B[0m: Marks a feature as deprecated but does not remove it so as not to break applications that use it."
  echo -e " * \x1B[93mdocs\x1B[0m: For documentation changes only."
  echo -e " * \x1B[93mfeat\x1B[0m: Implements a new feature."
  echo -e " * \x1B[93mfix\x1B[0m: Fix a bug or defect."
  echo -e " * \x1B[93minit\x1B[0m: Initialize a repository/project."
  echo -e " * \x1B[93mperf\x1B[0m: Change that improves performance."
  echo -e " * \x1B[93mrefactor\x1B[0m: Change that does not fix a bug or add functionality."
  echo -e " * \x1B[93msecurity\x1B[0m: Change that fixes a security vulnerability."
  echo -e " * \x1B[93mstyle\x1B[0m: Change that do not affect code execution (spaces, formatting, missing semicolon, etc)."
  echo -e " * \x1B[93mtest\x1B[0m: Addition of missing tests or correction of existing tests."
  echo -e "-------------------------------------------------------------------------------"
}
