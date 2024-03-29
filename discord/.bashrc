# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ -f ~/.tags-completion.bash ]; then
  source ~/.tags-completion.bash
fi

#source ~/local/shell/shellrc.sh

shopt -s checkwinsize
shopt -s histappend   # Append to history rather than overwrite

export PATH
unset USERNAME

# Create a scrubbed hostname
export HOSTNAME_SCRUB=`hostname | sed -e s/[^a-z0-9_]//g`

export EDITOR=`which vim`
export SVN_EDITOR=`which vim`
export GIT_EDITOR=`which vim`
export PAGER=`which less`
export GREP_OPTIONS='--color=auto'
export GIT_CEILING_DIRECTORIES=`echo $HOME | sed 's#\[^/]*$##'`

export HISTFILESIZE=1000000000
export HISTSIZE=1000000
export PROMPT_COMMAND='history -a'
export BROWSER='chrome'
#export LANG='en_US.utf8'
export LANG='C' # Testing: Try out the C locale
if [ -f "$HOME/.inputrc" ]; then
  export INPUTRC="$HOME/.inputrc"
fi;
export MAN_AUTOCOMP_FILE="/tmp/man_completes_`whoami`"

# Screen
export SCREEN_DIR="/var/run/screen/S-gmarcotte"
export SD=$SCREEN_DIR

export PATH=$PATH:/Users/$USER/depot_tools
export PATH=$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin
export PATH=$PATH:/usr/local/smlnj/bin
export PATH=$PATH:/opt/homebrew/bin

# Compatability options
# The BSD sed on mac uses -E, while the GNU one on linux uses -r
(echo '' | sed -r /GG/g &> /dev/null)
if [ $? -eq "0" ]; then
  export SED_EXT='-r'
else
  export SED_EXT='-E'
fi

# GNU vs BSD ls for color
(ls --color=tty &> /dev/null)
if [ $? -eq 0 ]; then
  export LS_COLOR='--color=tty'
else
  export LS_COLOR='-G'
fi;

#GNU vs BSD top command line arguments
# Delay updates by 10 sec and sort by CPU
(man top 2>&1 | grep Linux> /dev/null)
if [ $? -eq 0 ]; then
  export TOP_OPTIONS='-c -d10'
else
  export TOP_OPTIONS='-s10 -ocpu'
fi;

export LOG_NAME='error_log_gmarcotte'

# Aliases
alias ss='screen -x'
alias ls='ls -h $LS_COLOR'
alias la='ls -ah $LS_COLOR'
alias ll='ls -lah $LS_COLOR'
alias ssh='ssh -A'
alias g='git'
alias top='top $TOP_OPTIONS'
alias rcopy='rsync -az --stats --progress --delete'
alias ..='cl ..'
alias trim_whitespace="sed -i 's/[ \t]*$//' "
alias sush='sudo ssh'
alias http_headers='curl -svo /dev/null'
alias eb='vi ~/.bashrc; source ~/.bashrc'
alias sterm='xterm -r -geometry 140x60 &'
alias ld1='find . -maxdepth 1 -type d -print | sort'
alias m='less'
alias l='less'
alias log='tail -f ~/logs/$LOG_NAME | pretty'
alias vt='vim -t'
alias back='cd $OLDPWD'
alias up='cd ..'
alias reb='git fetch && git rebase trunk'
alias screens='ll /var/run/screen/S-gmarcotte'
alias gscr='cd $SCREEN_DIR'
alias fix='git commit -a --amend -CHEAD'

# Auto completion
complete -cf sudo
complete -cf which
#autocomplete ssh commands with the hostname
complete -W "$(echo `cat ~/.ssh/known_hosts 2> /dev/null | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh

# autocomplete man commands
function listmans_raw() {
  local manpath_func
  which manpath &> /dev/null
  if [ $? -eq 0 ]; then
    manpath_func='manpath'
  else
    manpath_func='man -W 2> /dev/null'
  fi;
  for dir in $($manpath_func | /usr/bin/tr ':' '\n'); do
    find "${dir}" ! -type d -name "*.*" 2>/dev/null | sed -e 's#/.*/##g' | sed -e 's#.[^.]*$##g' | sed -e 's#\.[0123456789].*##g'
  done
}
function regen_man_args() {
  listmans_raw | sort -u > $MAN_AUTOCOMP_FILE
}
function listmans() {
  if [ ! -f $MAN_AUTOCOMP_FILE ]; then
    regen_man_args
  fi;
  cat $MAN_AUTOCOMP_FILE
}
complete -W "$(listmans)" man


#### RANDOM FUNCTIONS #####
function jk {
  kill -9 %$1
}

# awesome!  CD AND LA. I never use 'cd' anymore...
function cl(){ cd "$@" && la; }
# Two standard functions to change $PATH
add_path() { export PATH="$PATH:$1"; }
add_pre_path() { export PATH="$1:$PATH"; }
# Misc utilities:

# Repeat a command N times.  You can do something like
#  repeat 3 echo 'hi'
function repeat()
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do
        eval "$@";
    done
}

# Lets you ask a command.  Returns '0' on 'yes'
#  ask 'Do you want to rebase?' && git svn rebase || echo 'Rebase aborted'
function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

#Simple blowfish encryption
function blow()
{
    [ -z "$1" ] && echo 'Encrypt: blow FILE' && return 1
    openssl bf-cbc -salt -in "$1" -out "$1.bf"
}
function fish()
{
    test -z "$1" -o -z "$2" && echo \
        'Decrypt: fish INFILE OUTFILE' && return 1
    openssl bf-cbc -d -salt -in "$1" -out "$2"
}

# Extract based upon file ext
function ex() {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1        ;;
             *.tar.gz)    tar xvzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       unrar x $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xvf $1        ;;
             *.tbz2)      tar xvjf $1      ;;
             *.tgz)       tar xvzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}
# Compress with tar + bzip2
function bz2 () {
  tar cvpjf $1.tar.bz2 $1
}

# Google the parameter
function google () {
  links http://google.com/search?q=$(echo "$@" | sed s/\ /+/g)
}

function myip () { 
 # GNU vs BSD hostname
 (hostname -i &> /dev/null)
  if [ $? -eq 0 ]; then
    echo `hostname -i`
  else
    # default to eth0 IP, for MAC
    echo `ipconfig getifaddr en0`
  fi;
}


# api <file.php>
# print the functions defined in the file
function api()
{
  if [ -f "$1" ]; then
    cat $1 | grep 'public'
    cat $1 | grep 'protected'
    cat $1 | grep 'private'
    cat $1 | grep 'function' | grep -v 'public' | grep -v 'private' | grep -v 'protected'
  fi;
}

# print the nth line of a file
function line()
{
  if [ -f "$1" ]; then
    head -n $2 $1 | tail -n 1
  fi;
}

function vimscan()
{
  vim `scan $1 | cut -f 1 -d : | uniq`
}

# res <file.php>
# for conflicts found when rebasing, edit a file then stage it for commit
function res()
{
  if [ -f "$1" ]; then
    vim $1 && hg resolve --mark $1
  fi;
}

function hres()
{
  if [ -f "$1" ]; then
    vim $1 && hg resolve --mark $1
  fi;
}

function gbr()
{
  for k in `git branch|perl -pe s/^..//`;do echo -e `git show --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k|head -n 1`\\t$k;done|sort -r
}

# anyvi <file>
# run EDITOR on a script no matter where it is
function anyvi()
{
    if [ -e "$1" ] || [ -f "$1" ]; then
        $EDITOR $1
    else
        $EDITOR `which $1`
    fi
}
complete -cf anyvi        #autocomplete the anyvi command

# Grep for a process while at the same time ignoring the grep that
# you're running.  For example
#   ps awxxx | grep java
# will show "grep java", which is probably not what you want
function psgrep(){
  local OUTFILE=`mktemp /tmp/psgrep.XXXXX`
  ps awxxx > $OUTFILE
  grep $@ $OUTFILE
  rm $OUTFILE
}

# Quick and dirty calculator.  Goes right to ruby and lets you print out
#   the results of math operations, or other ruby expressions
function calc(){ ruby -e "puts $*"; }

add_path $HOME/bin

# Set up git completion
source $HOME/.git-completion.bash

###### PROMPT ######
# Set up the prompt colors
PROMPT_COLOR=$G
if [ ${UID} -eq 0 ]; then
  PROMPT_COLOR=$R ### root is a red color prompt
fi

hg_ps1() {
  hg prompt "{({bookmark}) }" 2> /dev/null
}

prompt_br() {
  source ~/.scm-prompt
  br=`_dotfiles_scm_info`
  test -n "$br" && printf "(%s) " "$br"
}

# I like this prompt for a few reasons:
# (1) The time shows when each command was executed, when I get back to my terminal
# (2) Git information really important for git users
# (3) Prompt color is red if I'm root
# (4) The last part of the prompt can copy/paste directly into an SCP command
# (5) Color highlight out the current directory because it's important
# (6) The export PS1 is simple to understand!
# (7) If the prev command error codes, the prompt '>' turns red
#export PS1="$Y\t$N $W"'$(__git_ps1 "(%s) ")''$(hg_ps1)'"$N$PROMPT_COLOR\u@\H$N:$C\w$N\n"'$CURSOR_PROMPT '
export PS1="$Y\t$N $W"'$(prompt_br)'"$N$PROMPT_COLOR\u@\H$N:$C\w$N\n"'$CURSOR_PROMPT '
export PROMPT_COMMAND='if [ $? -ne 0 ]; then CURSOR_PROMPT=`echo -e "\033[0;31m>\033[0m"`; else CURSOR_PROMPT=">"; fi;'

# remove duplicate path entries and preserve PATH order
export PATH=$(echo $PATH | awk -F: '
{ start=0; for (i = 1; i <= NF; i++) if (!($i in arr) && $i) {if (start!=0) printf ":";start=1; printf "%s", $i;arr[$i]}; }
END { printf "\n"; } ')


eval $(dircolors ~/.dir_colors)

