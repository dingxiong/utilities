#!/bin/bash

# set -e 


code_root="$HOME/code"
repo_name=configure
repo_addr=git@github.com:dingxiong/configure.git

devbox_cleanup() {

  rm -rf ${code_root}/${repo_name}
  rm -rf ~/.inputrc

  # remove .zshrc change
  sed -i '/#XIONG_BEGIN/,/#XIONG_END/d' ~/.zshrc

  # remove nvim configs 
  rm -rf ~/.local/share/nvim
  rm -rf ~/.config/nvim/init.vim
  rm -rf ~/.config/nvim/lua/plugins.lua

}

devbox_config() {
  # first check ssh key is set up correctly 
  if [[ ! -f $HOME/.ssh/id_rsa ]] ; then 
    echo "Please copy localhost ssh key to devbox first"
    echo "Example: "
    echo "    scp ~/.ssh/id_rsa devbox:/home/admin/.ssh/"
    echo "    scp ~/.ssh/id_rsa.pub devbox:/home/admin/.ssh/"
    exit 1
  fi

  pushd .
  mkdir -p ${code_root}
  cd ${code_root}
  git clone $repo_addr 
  cd $repo_name

  # zsh use ZLE as line editor. inputrc is not used in readline instead.
  # ln -s ${code_root}/${repo_name}/inputrc ~/.inputrc 
 
  ln -s ${code_root}/${repo_name}/ripgreprc ~/.ripgreprc

  # install some basic softwares
  sudo apt-get update || true
  sudo apt-get install -y htop ripgrep clangd golang gopls gccgo gdb lua5.3 cmake stress-ng

  # install rust related tools
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env
  if ! command -v rustup >/dev/null 2>&1; then
    echo "rustup is not installed yet."
  fi
  rustup component add rust-analyzer

  # install npm related stuff

  # Need this for nvim lsp
  # https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ts_ls
  npm install -g typescript typescript-language-server bash-language-server


  # install neovim
  # https://github.com/neovim/neovim/blob/master/INSTALL.md
  # Tmux has some issue with nvim 0.10.0
  # https://github.com/tmux/tmux/issues/3983
  wget https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
  if [[ ! -f nvim-linux-x86_64.tar.gz ]] ; then 
    echo "Fail to download nvim, please check if the link is outdated or not."
    exit 1
  fi
  sudo rm -rf /opt/nvim-linux64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm nvim-linux-x86_64.tar.gz

  # .zshrc set up
  if  [[ -f ~/.zshrc && -z $(grep "xiong" ~/.zshrc) ]] ; then
    cat << 'EOT' >> ~/.zshrc
#XIONG_BEGIN
setopt shwordsplit
export PAGER="less -F -X"
bindkey -e
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"

bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

alias cd.='cd ..'
alias cd..='cd ../..'
alias cd...='cd ../../..'
alias ll='ls -ltrah --color=auto'
# see https://unix.stackexchange.com/questions/25327/watch-command-alias-expansion
alias watch='watch '

alias vim='nvim'
alias ipytest='pytest --pdbcls=IPython.terminal.debugger:TerminalPdb -s --log-cli-level=INFO'

export TEST_DB_URL=test
export RSPACK_NO_OPEN=1
export DEV_EMAIL=xiong@ziphq.com
export FORCE_SKIP_BOT_LOGGING=1

# keep devbox a little busy, so it won't be killed
if ! crontab -l 2>/dev/null | grep -q 'stress-ng' ; then
    echo "Install stress-ng cronjob"
    (crontab -l; echo "*/2 * * * * stress-ng --cpu 1 --cpu-load 20 --timeout 122s &") | crontab -
fi

#XIONG_END
EOT
  fi

  source ~/.zshrc

  # set up nvim 
  mkdir -p ~/.config/nvim/lua

  # we still need this legacy plugin manager
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  
  # packer
  git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
  ln -s ${code_root}/${repo_name}/init.vim ~/.config/nvim/init.vim
  ln -s ${code_root}/${repo_name}/plugins.lua ~/.config/nvim/lua/plugins.lua

  nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

  popd 
}

devbox_cleanup
devbox_config

