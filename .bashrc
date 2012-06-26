#man coloring
export MANPAGER="/usr/bin/most -s"

#----------Color
# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensty
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensty
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensty backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[10;95m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

# Options
shopt -s dotglob
shopt -s extglob
shopt -s nocaseglob
shopt -s cmdhist
shopt -s histappend
shopt -s expand_aliases
shopt -s checkwinsize
shopt -s cdspell
shopt -s no_empty_cmd_completion

#autocomplete
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
export JAVA_HOME=/usr/lib/jvm/java-6-sun/
export HISTTIMEFORMAT="%h/%d - %H:%M:%S "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable color support of ls and also add handy aliases
COLOR1="\[\033[0;36m\]"
COLOR2="\[\033[1;32m\]"
COLOR3="\[\033[0;36m\]"
COLOR4="\[\033[0;37m\]"
COLOR5="\[\033[1;33m\]"
LSCOLORS="DxGxFxdxCxdxdxhbadExEx"
export LSCOLORS
PATH=PATH$:/sbin:/bin:/usr/bin:/opt/local/bin
if [ "$UID" = "0" ];
then
# I am root
COLOR2="\[\033[1;31m\]"
fi
if [ "$TERM" != "dumb" ]; then
    eval `dircolors -b`
    alias ls='ls --color=always'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
fi
#safe delete
alias rm='rm -i'

# some more ls aliases
alias less='less -SR'
alias l='ls -lLBhX --time-style=locale'
alias la='ls -la $1 | less'
alias ll='ls -lX'
alias lx='ls -lXB' #sort by ext
alias lk='ls -lSr' #soft by size

# Alias's to modifed commands
alias ps='ps auxf'
alias home='cd ~'
alias pg='ps aux | grep' #requires an argument
alias lg='ls -la | grep' #requires an argument
alias un='tar -zxvf'
alias df='df -hT'
alias ping='ping -c 10'
alias net-restart='sudo /etc/init.d/networking restart'
#alias windir="cd '/home/hkvn/.wine/drive_c/Program Files'"
alias ..='cd ..'
alias update='sudo apt-get update'
alias upgrade='sudo apt-get upgrade'
alias install='sudo apt-get install'
alias remove='sudo apt-get remove'
alias eclipse='eclipse -vmargs -Xmx512M'
alias firefox='firefox-3.5'
alias ipconfig='ifconfig -a'

# Some ssh connections
alias chy='ssh chuyenhungyen.org -l thanhbv'
alias xalo='sudo vpnc-connect xalo.conf'

# Some ping commands
#alias pga='ping 192.168.1.1 -c 10'
alias pyh='ping yahoo.com -c 10'
alias pgg='ping google.com.vn -c 10'
alias pggvn='ping google.com.vn -c 10'

#Some chmod commands
alias mx='chmod a+x'
alias 000='chmod 000'
alias 644='chmod 644'
alias 755='chmod 755'
alias 777='chmod 777'


# more
trap 'echo -ne "\e[0m"' DEBUG

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in
# if [ -z "$debian_chroot" -a -r /etc/debian_chroot ]; then
#     debian_chroot=$(cat /etc/debian_chroot)
# fi

#disable the annoying beeps
#echo -ne "\33[11;0]"

#ANSI color code
#echo -e "\033[1mBold\033[0m -- \033[01;04mBold and Underline\033[0m -- \033[4mUnderline\033[0m"
#Foreground colors: 30=black;31=red;32=green;33=red;34=blue;35=magenta;36=cyan;37=white;38=?;39=white(default);
#Background colors: 40=black;41=red;42=green;43=red;44=blue;45=magenta;46=cyan;47=white;48=?;49=black(default);

# Comment in the above and uncomment this below for a color prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]: \[\033[01;34m\]\w\[\033[00m\] \$ '
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\w\[\033[00m\] \$ '
PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[0;31m\]\$ \[\e[m\]\[\e[0;32m\]'

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
*)
    ;;
esac

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc).
# if [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
# fi

# SPECIAL FUNCTIONS
netinfo ()
{
echo "--------------- Network Information ---------------"
/sbin/ifconfig | awk /'inet addr/ {print $2}'
echo ""
/sbin/ifconfig | awk /'Bcast/ {print $3}'
echo ""
/sbin/ifconfig | awk /'inet addr/ {print $4}'
echo ""
ip route show | grep 'default via'
echo "---------------------------------------------------"
}
function r ()
{
 su -c "$*"
}

export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
