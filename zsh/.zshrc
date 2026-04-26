## .zshrc for ZSH 4.x/5.x
# When I run in non-interactive session, do not anything.
#
case $- in
    *i*) ;;
      *) return;;
esac

typeset -U PATH
path=(
    $HOME/bin $HOME/sbin
    $HOME/pkg/bin $HOME/pkg/sbin
    $HOME/.local/bin 
    /usr/local/bin /usr/local/sbin
#   /usr/pkg/bin /usr/pkg/sbin
    /bin /sbin
    /usr/bin /usr/sbin
    $path
#    /usr/X11R6/bin
#    /usr/games
#    /opt/sfw/bin/ /opt/sfw/sbin
#    /usr/local/ssl/bin
    )

if [ ${UID} != "0" ]; then
    fpath=(~/.zsh/completion $fpath)
fi

## Gentoo Prefix
# export EPREFIX="$HOME/Gentoo"
# path=(
#         $EPREFIX/usr/bin $EPREFIX/bin $EPREFIX/tmp/usr/bin $EPREFIX/tmp/bin
#         $path
#      )
#

###
# [ Set shell options ]
###
setopt always_last_prompt always_to_end
setopt auto_list auto_menu auto_name_dirs auto_param_keys auto_pushd auto_param_slash 
setopt cdable_vars correct complete_in_word complete_aliases
setopt long_list_jobs
setopt extended_glob extended_history equals
setopt hist_ignore_dups hist_verify hist_reduce_blanks
setopt ignore_eof inc_append_history
setopt list_types listpacked
setopt multios magic_equal_subst mark_dirs
setopt numeric_glob_sort
setopt no_beep no_clobber no_flow_control no_notify no_list_beep
setopt nopromptcr noautoremoveslash
setopt prompt_subst pushd_ignore_dups pushd_to_home
setopt print_eight_bit
setopt rm_star_silent
setopt sh_word_split share_history
setopt transient_rprompt

autoload -Uz is-at-least
autoload -Uz add-zsh-hook

# vim like completations
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# < history >

HISTFILE=$HOME/.zsh-history
HISTSIZE=100000
SAVEHIST=10000
LISTMAX=0
function history-all { history -E 1 }

##
# [ set alias ]
###

#alias rr="rm -rf"
alias ls="/bin/ls"
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias pd="pushd"
alias po="popd"
alias gd='dirs -v; echo -n "select number: "; read newdir; cd +"$newdir"'
alias view='view -Mn'
alias history='history -f'
alias xo='xdg-open'
alias py='python'
alias time='/usr/bin/time'
alias taskshell='ZDOTDIR=~/.task zsh'
alias ssv='ss --options --extended --memory --processes --info'

# Care for Vim/vi
alias vi="vim -u .vimcprc"

# expand URL shortcuts (such ad bit.ly)
function expandurl() { wget -S $1 2>&1 | grep ^Location; }

function temp() {
    # you can set "$_WORKDIR", it is overridable.
    ARG="$1"
    TODAY=${TODAY:-`/bin/date '+%Y/%m%d'`}
    _WORKDIR=${_WORKDIR:-"${HOME}/work"}
    TMP="${_WORKDIR}/${ARG}/${TODAY}"
    echo $TMP
    if [ ! -d "${TMP}" ] ; then
        mkdir -pv "${TMP}"
    fi
    cd "${TMP}"
}

# < csh compatible setting :: "setenv" >
    alias unsetenv=unset
function setenv () {
        if [ $# -eq 0 ]; then
            /usr/bin/env
        else
            export $1=$*[2,-1]
        fi
    }

# < procedure: extend cd >
function cd() {
        if builtin cd "$@" ; then
            print -D ' {' $(/bin/ls -d -l "$(pwd)") '}';
        fi
    }

# < procedure: extend alias >
function xalias(){
        if [ x`whence $2` != "x" ]; then
            alias $1="$*[2,-1]"
        fi
    }

# < procedure: easy password >
function genpass(){
    length="${1:-"8"}"
    cat /dev/urandom | base64 | head -c $(( ${length} *2 ))| tail -c "${length}"
    echo
}

# color ls (for gnuls, POSIX ls)
LS_COLORS="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;3:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:"
    export LS_COLORS

    if [ $(uname) = "Linux" ];
        then
            alias ls="/bin/ls -F --color=auto"
            alias la="/bin/ls -lhAF --color=auto"
            alias ll='/bin/ls -la --color=auto'
        else
            alias ls="ls -F"
            alias la="ls -lhAF"
            alias ll='ls -la'
            if [ -x /usr/pkg/bin/gls ]; then
                alias ls="gls -F --color=auto"
                alias la="gls -lhAF --color=auto"
                alias ll='gls -la --color=auto'
            fi
    fi


# lesspiple
for i in lesspipe{,.sh} ; do tLESSPIPE=`which $i 2>/dev/null` && LESSPIPE=${tLESSPIPE}; done;
if [ ! -z ${LESSPIPE} ]; then
    export LESSCLOSE="${LESSPIPE} %s %s"
    export LESSOPEN="| ${LESSPIPE} %s"
fi

# command_not_found
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

## color difinitions
# // colors feature for old environmnets
    local GRAY=$'%{\e[0;30m%}'
    local LIGHT_GRAY=$'%{\e[0;37m%}'
    local WHITE=$'%{\e[0;37m%}'
    local LIGHT_BLUE=$'%{\e[0;36;1m%}'
    local YELLOW=$'%{\e[0;33m%}'
    local PURPLE=$'%{\e[0;35m%}'
    local GREEN=$'%{\e[0;32m%}'
    local BLUE=$'%{\e[0;34m%}'
    local RED=$'%{\e[0;31;1m%}'
    local DEFAULT=$'%{\e[0;m%}'

bindkey -e # Emacs like Keybind
#bindkey -v # vi like Keybind

## VCS support
setopt PROMPT_SUBST
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' formats       '%F{white}%K{black} %s:%r/%S %b%f%k'
zstyle ':vcs_info:*' actionformats '%F{white}%K{black} %s:%r/%S %b(->%a)%f%k'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%K{blue}%F{white} [%b:r%r] %f%k'
zstyle ':vcs_info:bzr:*' use-simple true

if is-at-least 4.3.10; then
zstyle ':vcs_info:git*+set-message:*' hooks git-st
    zstyle ':vcs_info:bzr:*' check-for-changes true
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr   "%B%K{yellow}%F{black} + %b" #%c
    zstyle ':vcs_info:git:*' unstagedstr "%B%K{red}%F{white} ? %b"  #%u
    zstyle ':vcs_info:git:*' formats       '%K{black}%F{white} %s:%r %K{white}%F{black}%f%k%K{blue}%F{white}[ %b ]%f%k%m%c%u'
    zstyle ':vcs_info:git:*' actionformats '%K{black}%F{white} %s:%r %K{white}%F{black}%f%k%K{magenta}%F{white}[ %b ]%f%k(->%a)%m%c%u'
function _update_vcs_info_msg() {
    psvar=()
    LANG=C vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
add-zsh-hook precmd _update_vcs_info_msg
fi

## extended Script stuffs
local SCRIPTDIR=~/scr
local TIMING=timing

function scr {
    if [ ! -e ${SCRIPTDIR} ]; then
        mkdir -p ${SCRIPTDIR}
    fi
    ARG=$1
    local SCRIPTFILE=${SCRIPTDIR}/`date "+%F_%H%M_%s"`_${ARG}
    LANG=C script --log-out ${SCRIPTFILE} --log-timing ${SCRIPTFILE}.${TIMING}
    gzip ${SCRIPTFILE}
    gzip ${SCRIPTFILE}.${TIMING}
}


function scrreplay {
    SCRIPTFILE=${1%.gz}
    gunzip ${SCRIPTFILE}.gz
    gunzip ${SCRIPTFILE}.${TIMING}.gz
    echo
    echo "scriptreplay:begin $1 / divisor=$2"
    echo
    scriptreplay ${SCRIPTFILE}.${TIMING} ${SCRIPTFILE} $2
    echo
    echo "scriptreplay:end"
    echo
    gzip ${SCRIPTFILE}
    gzip ${SCRIPTFILE}.${TIMING}
}

###
# [ complement setting ]
###
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
autoload -Uz promptinit && promptinit
autoload -Uz incremental-complete-word
zle -C complete complete-word complete-file
zle -N incremental-complete-word

SPROMPT='zsh: correct '%R' to '%r' ? ([Y]es/[N]o/[E]dit/[A]bort) '

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'%{\e[1;33m%}%d%{\e[0m%}'
zstyle ':completion:*:messages' format $'%{\e[1;33m%}%d%{\e[0m%}'
zstyle ':completion:*:warnings' format $'%{\e[1;33m%}No matches for: %d%{\e[0m%}'
zstyle ':completion:*:corrections' format $'%{\e[1;33m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:rm:*' ignore-line yes
zstyle ':completion:*' list-colors "$LS_COLORS"
zstyle ':completion:*' file-sort name
zstyle ':completion:*' menu select=long
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.(o|c~|old|pro|zwc)'
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~''*?.old' '*?.pro'
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z} r:|[-_.]=**'
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
    /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# group by tag names
zstyle ':completion:*' group-name ''




###
# [ export env ]
###

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib:/usr/lib:/usr/local/lib
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/X11R6/lib
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/pkg/lib
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/ports/lib

export EDITOR=vim
export VISUAL=${EDITOR}



# one-liners
alias bell='echo \\a'

###
# [ Terminal setting ]
###

case "$TERM" in
xterm|kterm|rxvt)
    precmd() {
        print -Pn "\e]0; [ %~ | %n@%m ]  ${TTY} \a"
    }

    preexec() {
        print -Pn "\e]0; [ { \"$1\"  } | %n@%m ]  ${TTY} \a"
    }
;;
screen|screen-*|screen.*)
        precmd(){
            SCREEN_ITEM="\ek%(?.%m.$MY_ZSH_EXEC=>{%?})\e\\"
            print -Pn "${SCREEN_ITEM}"
        }
        preexec() {
            MY_ZSH_EXEC=`echo "$1"|head -c 12`
            SCREEN_ITEM="\ek${MY_ZSH_EXEC}\e\\"
            print -Pn "${SCREEN_ITEM}"
        }
;;
esac

##### Enum personal env var #####
export DEBFULLNAME="Fumihito YOSHIDA"
export DEBEMAIL=hito@kugutsu.org
export MYEMAIL=${DEBEMAIL}

# set developers deciplines
export GPG_TTY=`tty`
export QUILT_DIFF_OPTS="-F ^[[:alpha:]\$_].*[^:]\$"

# set python shell config
export PYTHONSTARTUP=~/.pythonrc

## some non-glob commands
alias scp='noglob command scp'
alias wget='noglob command wget'
alias find='noglob command find'

## Hexdump stuffs
alias hexdump_mbr="hexdump -s 446 -n 64 -e '8/1 \"%02x \" 2/4 \"%10d \" \"\n\"'"
alias hexdump_parttion="hexdump -s 446 -n 64 -v -e '1/1 \"%02x\" 3/1 \" %3d\" 1/1 \" %02x\" 3/1 \" %3d\" 2/4 \" %9d\" \"\n\"'"
alias str2num="hexdump -v -e '8/1 \"%03o\" \"\n\"'"

## LANGUAGE stuffs
alias eng='LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_MESSAGES=en_US.UTF-8'
alias engc='LANG=C LANGUAGE=C LC_MESSAGES=C'
alias euc='LANG=ja_jp.EUC-JP LANGUAGE=ja_jp.EUC-JP LC_MESSAGES=ja_jp.EUC-JP'
alias jpn='LANG=ja_JP.utf8 LANGUAGE=ja_JP.utf8 LC_MESSAGES=ja_JP.utf8'
alias jpn2='LANG=ja_JP.UTF-8 LANGUAGE=ja_JP.UTF-8 LC_MESSAGES=ja_JP.UTF-8'
jpn

function show_lang {
   echo "LANG=\"${LANG}\"; LANGUAGE=\"${LANGUAGE}\" ; LC_ALL=\"${LC_ALL}\""
   echo "LC_MESSAGES=\"${LC_MESSAGES}\""
}

## copy from Debian/Ubuntu's default .bashrc
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='grep -F --color=auto'
    alias egrep='grep -E --color=auto'
fi


#

## build up prompt{{{
# ---- host-based safe prompt colors ---------------------------------

# first 8 chars will be consumed for key selection
: ${HOST_COLOR_KEYLEN:=8}

# key string from hostname
_host_color_key() {
  emulate -L zsh
  local h=${1:-${HOST%%.*}}   # foo.example.com -> foo
  # 先頭 N 文字だけ使う
  print -r -- "${h[1,$HOST_COLOR_KEYLEN]}"
}

# easy FNV-1a (32bit) hash function
_host_color_hash() {
  emulate -L zsh
  local s="${1:-$(_host_color_key)}"
  local -i i c h=2166136261

  for (( i = 1; i <= ${#s}; ++i )); do
    c=$(printf '%d' "'${s[i]}")
    (( h ^= c ))
    (( h *= 16777619 ))
    (( h &= 0xffffffff ))
  done

  print -r -- "$h"
}

# color enum for 256 color env
typeset -ga HOST_COLOR_PAIRS_256=(
  '231:17'   # white on navy
  '230:18'   # ivory on dark blue
  '255:19'   # bright gray on deeper blue
  '252:20'   # gray on blue

  '230:22'   # ivory on dark green
  '223:23'   # pale peach on deep green
  '231:24'   # white on teal
  '189:25'   # pale blue on blue

  '223:52'   # pale peach on maroon
  '230:53'   # ivory on purple
  '189:54'   # pale blue on violet
  '255:55'   # bright gray on purple

  '230:58'   # ivory on olive
  '255:59'   # bright gray on muted gray-brown
  '189:60'   # pale blue on slate purple

  '231:88'   # white on dark red
  '223:89'   # pale peach on magenta-red
  '230:90'   # ivory on dark magenta
  '255:94'   # bright gray on purple
  '189:95'   # pale blue on plum
  '231:96'   # white on plum-purple

  '231:130'  # white on brown/orange
  '254:235'  # very light gray on dark gray
  '252:236'  # gray on dark gray
  '250:237'  # soft gray on gray
  '255:238'  # bright gray on lighter gray
)

# color enum for 16 color env
typeset -ga HOST_COLOR_PAIRS_16=(
  '15:4'   # white on blue
  '15:2'   # white on green
  '15:5'   # white on magenta
  '15:1'   # white on red
  '11:4'   # yellow on blue
  '14:0'   # cyan on black
  '15:8'   # white on bright black
  '0:7'    # black on white
)

# color picker
_host_pick_color_pair() {
  emulate -L zsh
  local key hash pair
  local -i colors idx

  key="${1:-$(_host_color_key)}"
  hash=$(_host_color_hash "$key")

  colors=$(tput colors 2>/dev/null)
  [[ -z "$colors" ]] && colors=0

  if (( colors >= 256 )); then
    (( idx = (hash % ${#HOST_COLOR_PAIRS_256}) + 1 ))
    pair="${HOST_COLOR_PAIRS_256[idx]}"
  elif (( colors >= 8 )); then
    (( idx = (hash % ${#HOST_COLOR_PAIRS_16}) + 1 ))
    pair="${HOST_COLOR_PAIRS_16[idx]}"
  else
    pair='0:0'
  fi

  print -r -- "$pair"
}

# init procedure
_host_apply_prompt_colors() {
  emulate -L zsh
  local pair="${1:-$(_host_pick_color_pair)}"
  export MYHOSTCOLOR_FG="${pair%%:*}"
  export MYHOSTCOLOR_BG="${pair##*:}"
}

# exec init
_host_apply_prompt_colors

# preview
my-host-color-preview() {
  emulate -L zsh
  local name pair fg bg
  name="${1:-${HOST%%.*}}"
  pair=$(_host_pick_color_pair "$name")
  fg="${pair%%:*}"
  bg="${pair##*:}"
  print -P "%K{$bg}%F{$fg} ${name}  fg=${fg} bg=${bg} %f%k"
}

# preview with multiple stuffs
my-host-color-preview-many() {
  emulate -L zsh
  local n
  for n in "$@"; do
    host-color-preview "$n"
  done
}

RPROMPT=[$LIGHT_GRAY%F{green}%K{black}%U%~%u%f%k]  
PROMPT="%K{black}%n@%K{${MYHOSTCOLOR_BG}}%F{${MYHOSTCOLOR_FG}}%m%f%k %(?.$LIGHT_BLUE.$RED)%?"$'%b %F{grey}{$LANG}%f%k%F{cyan} %D{%m-%d %R(%Z)}%f $(ssh_agent_prompt)$(tmux_attachable_prompt)$(wsl_prompt)${vcs_info_msg_0_}%f%k\n$GREEN%(!.#.$) $DEFAULT'
#}}

### VTE_CJK_WIDTH (for SSH sessions)
VTE_CJK_WIDTH_PROFILE=/etc/profile.d/vte_cjk_width.sh
if [ -f ${VTE_CJK_WIDTH_PROFILE} ]; then
    source ${VTE_CJK_WIDTH_PROFILE}
fi

## ssh-agent quirks and add exsitence checking function

alias ssh-agent="ssh-agent -a ${HOME}/.ssh/ssh-agent.sock"
export SSH_AUTH_SOCK="${HOME}/.ssh/ssh-agent.sock"

function ssh_agent_prompt() {
  if [[ -z "$SSH_AUTH_SOCK" ]]; then
    echo "%F{red}%K{black}[ssh-agent:no]%f"
    return
  fi

  ssh-add -l >/dev/null 2>&1
  local ssh_agent_status=$?

  case $ssh_agent_status in
    0)
      echo "%F{green}%K{black}[ssh-agent:ready]%f"
      ;;
    1)
      echo "%F{yellow}%K{black}[ssh-agent:nokey]%f"
      ;;
    *)
      echo "%F{red}%K{black}[ssh-agent:no]%f"
      ;;
  esac
}

## tmux a awareness
function tmux_attachable_prompt() {
  if [[ -n "$TMUX" ]]; then
    echo "%F{green}[in-tmux]%f"
    return
  fi

  if command -v tmux >/dev/null 2>&1 && tmux ls >/dev/null 2>&1; then
    echo "%F{yellow}[tmux session exists]%f"
  else
    echo "%F{red}[no tmux]%f"
  fi
}

## wsl detection (easy, and heuristic)
function wsl_prompt() {
  if [[ -e /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
    echo "%F{magenta}(wsl)%f"
  fi
}

## tmux window rename
_tmux_rename_preexec() {
  [[ -z "$TMUX" ]] && return
  local cmd="${1%% *}"
  case "$cmd" in
    claude|codex) tmux rename-window "$cmd" ;;
  esac
}

_tmux_autorename_precmd() {
  [[ -z "$TMUX" ]] && return
  tmux set-window-option automatic-rename on 2>/dev/null
}

add-zsh-hook preexec _tmux_rename_preexec
add-zsh-hook precmd  _tmux_autorename_precmd

##### Starting ZSH #####
## Normal interactive shell {{{
    ## echo system information
    if [ -x /bin/uname ]; then
        CODE=`(lsb_release -d | cut -f2) 2> /dev/null`
        echo "I am $(hostname) ( $(uname -s),$(uname -m) ) . ${CODE}"
    else
        echo This box is $(hostname)
    fi

    echo "   zsh version: $ZSH_VERSION"
    echo "  $(uptime 2>/dev/null)"
# }}}

# vim:set foldmethod=marker:
