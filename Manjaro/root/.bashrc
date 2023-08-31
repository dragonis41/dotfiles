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
alias update='yay -Syyu'
alias yay='yay --answerclean All --answerdiff None --answeredit None --cleanafter --removemake --sudoloop'

# Alias for Git Hooks
# pre-commit
alias activate.pre-commit.all='chmod +x ~/.git-hooks/pre-commit.d/*'
alias deactivate.pre-commit.all='chmod -x ~/.git-hooks/pre-commit.d/*'
alias activate.pre-commit.01.check-for-private-key='chmod +x ~/.git-hooks/pre-commit.d/01.check-for-private-key.hook'
alias deactivate.pre-commit.01.check-for-private-key='chmod -x ~/.git-hooks/pre-commit.d/01.check-for-private-key.hook'
alias activate.pre-commit.02.check-for-env-file='chmod +x ~/.git-hooks/pre-commit.d/02.check-for-env-files.hook'
alias deactivate.pre-commit.02.check-for-env-file='chmod -x ~/.git-hooks/pre-commit.d/02.check-for-env-files.hook'
alias activate.pre-commit.03.check-for-credentials='chmod +x ~/.git-hooks/pre-commit.d/03.check-for-credentials.hook'
alias deactivate.pre-commit.03.check-for-credentials='chmod -x ~/.git-hooks/pre-commit.d/03.check-for-credentials.hook'
alias activate.pre-commit.04.remove-trailing-space='chmod +x ~/.git-hooks/pre-commit.d/04.remove-trailing-space.hook'
alias deactivate.pre-commit.04.remove-trailing-space='chmod -x ~/.git-hooks/pre-commit.d/04.remove-trailing-space.hook'
alias activate.pre-commit.05.fix-end-of-file='chmod +x ~/.git-hooks/pre-commit.d/05.fix-end-of-files.hook'
alias deactivate.pre-commit.05.fix-end-of-file='chmod -x ~/.git-hooks/pre-commit.d/05.fix-end-of-files.hook'
alias activate.pre-commit.06.format-go-file='chmod +x ~/.git-hooks/pre-commit.d/06.format-go-files.hook'
alias deactivate.pre-commit.06.format-go-file='chmod -x ~/.git-hooks/pre-commit.d/06.format-go-files.hook'
alias activate.pre-commit.07.validate-json-files='chmod +x ~/.git-hooks/pre-commit.d/07.validate-json-files.hook'
alias deactivate.pre-commit.07.validate-json-files='chmod -x ~/.git-hooks/pre-commit.d/07.validate-json-files.hook'
alias activate.pre-commit.08.validate-xml-files='chmod +x ~/.git-hooks/pre-commit.d/08.validate-xml-files.hook'
alias deactivate.pre-commit.08.validate-xml-files='chmod -x ~/.git-hooks/pre-commit.d/08.validate-xml-files.hook'
# commit-msg
alias activate.commit-msg.all='chmod +x ~/.git-hooks/commit-msg.d/*'
alias deactivate.commit-msg.all='chmod -x ~/.git-hooks/commit-msg.d/*'
alias activate.commit-msg.01.check-message='chmod +x ~/.git-hooks/commit-msg.d/01.check-message.hook'
alias deactivate.commit-msg.01.check-message='chmod -x ~/.git-hooks/commit-msg.d/01.check-message.hook'
# post-update
alias activate.post-update.all='chmod +x ~/.git-hooks/post-update.d/*'
alias deactivate.post-update.all='chmod -x ~/.git-hooks/post-update.d/*'
alias activate.post-update.01.update-server-info='chmod +x ~/.git-hooks/post-update.d/01.update-server-info.hook'
alias deactivate.post-update.01.update-server-info='chmod -x ~/.git-hooks/post-update.d/01.update-server-info.hook'

# Fonctions
mk() {
	mkdir -p -- "$1" && touch -- "$1"/"$2" && cd -- "$1" && ls -laF
}
search() {
	find -L . -name "*$**"
}
searchcontent() {
	fd --type f --exec grep "$*" --color=always
}
get_cpu_temp() {
	CEL=$'\xc2\xb0C';
	temp=$(cat /sys/devices/virtual/thermal/thermal_zone10/temp);
	temp=`expr $temp / 1000`;
	echo $temp$CEL;
}
git-hooks() {  # TUI to de/activate git hooks
  # Define the directories
  local directories=("$HOME/.git-hooks/pre-commit.d" "$HOME/.git-hooks/commit-msg.d" "$HOME/.git-hooks/post-update.d")

  # Create an array to hold the files and their permissions
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
