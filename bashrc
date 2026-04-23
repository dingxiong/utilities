source $HOME/code/configure/shrc.sh

export PS1="\[\e[31m\]\D{%F %T} (bash) \[\e[32m\]\w\n\[\e[m\]\$ "

HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
HISTSIZE=50000
HISTFILESIZE=50000

delete_test_dbs() {
  x=$(mysql -uroot -ppassword -e "show databases;" --vertical | grep test- | awk -F: '{print $2}')
  for i in ${x[@]}; do
    echo "deleting db $i ..."
    mysql -uroot -ppassword -e "drop database \`${i}\`" ;
  done
}

if [[ -z $TMUX ]]; then
  eval "$(rbenv init - bash)"
  eval "$(pyenv init -)"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/xiongding/.lmstudio/bin"
