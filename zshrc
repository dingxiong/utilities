#!/bin/bash
source $HOME/code/configure/shrc.sh 

PROMPT="%F{red}%D %*%f %F{green}%~%f"$'\n'"%# "

setopt share_history

# stop rendering a new screen in git branch
# unset LESS 
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward

bindkey "[D" backward-word
bindkey "[C" forward-word
# for tmux 
bindkey "OD" backward-word
bindkey "OC" forward-word

# auto complete
autoload -Uz compinit && compinit


# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/xiongding/.lmstudio/bin"
