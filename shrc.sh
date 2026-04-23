#!/bin/bash

# common config for both bash and zsh

source ~/.nvm/nvm.sh

if [[ -z $TMUX ]]; then
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  export PATH="$PATH:/Users/xiongding/code/istio-1.16.0/bin"
  export PATH=/Users/xiongding/bin:$PATH
  # add go bin path
  export PATH=$PATH:$HOME/go/bin
  export PATH=/opt/homebrew/opt/bison/bin:$PATH
  # add vcpkg
  export PATH=$PATH:$HOME/code/vcpkg
  export PATH=/opt/homebrew/opt/postgresql@16/bin:$PATH
fi

########### begin zip specific ########### 
export PATH_TO_EVERGREEN=/Users/xiongding/code/evergreen/website # or wherever you cloned the repo
export PYTHONPATH=$PYTHONPATH:$PATH_TO_EVERGREEN/gen-py
export DEVELOPMENT=1
export ENV_LOCAL=1
export MYSQL_HOST=localhost
export MYSQL_USER=root
export MYSQL_PASSWORD=password
export SERVER_DEV_PORT=6000
export ZIP_LOGGING_LEVEL=INFO
export DEV_EMAIL=xiong@ziphq.com
export DEV_SLACK_ID=U03AF375GLB
export DISABLE_UVLOOP=1

alias k="kubectl"
alias kx='kubectx'

thriftgen() {
    include_dir="$(pwd)"

    (
        for f in $(find thrift -name "*.thrift")
        do
            thrift -I $include_dir -r --gen py:enum $f &
        done
    )

    yarn thrift-gen
}
protogen () {
	relative_py_out_dir="protogen"
	relative_ts_out_dir="assets/protogen"
	rm -rf "$(pwd)/$relative_py_out_dir" "$(pwd)/$relative_ts_out_dir"
	mkdir -p "$(pwd)/$relative_py_out_dir" "$(pwd)/$relative_ts_out_dir"
	ts_proto_bin="./node_modules/.bin/protoc-gen-ts_proto"
	[[ $IS_DOCKER == 'true' ]] && zconst_bin="./bin/protoc-gen-zconst-dev-docker"  || zconst_bin="./bin/protoc-gen-zconst-dev-local"
	protoc --python_betterproto_out=$relative_py_out_dir --plugin=protoc-gen-zconst=$zconst_bin --zconst_out=codegen_format=all,py_out_dir=$relative_py_out_dir,ts_out_dir=$relative_ts_out_dir:. --plugin=protoc-gen-ts_proto=$ts_proto_bin --ts_proto_opt=env=browser --ts_proto_opt=unrecognizedEnum=false --ts_proto_opt=exportCommonSymbols=false --ts_proto_opt=onlyTypes=true --ts_proto_opt=forceLong=bigint --ts_proto_opt=removeEnumPrefix=false --ts_proto_out=$relative_ts_out_dir $(find protos -name "*.proto")
}


ksshserver() {
   LOGIN_USER=$DEV_EMAIL
   if [[ -z $LOGIN_USER ]]; then
     LOGIN_USER=`git config user.email`
   fi
   if [[ -z $LOGIN_USER ]]; then
     LOGIN_USER=`aws sts get-caller-identity | grep UserId | grep -E -o '[^:]+@ziphq.com'`
   fi
   echo "Logging in $1 as $LOGIN_USER"
   # k exec -it $(k get pod -o=jsonpath='{.items[0].metadata.name}' -l app=evergreen-server -n $1) -n $1 -- bash -c "export DEV_EMAIL=$LOGIN_USER; bash"
   k exec -it "$@" -- bash -c "export DEV_EMAIL=$LOGIN_USER; bash"
}

kscpserver() {
   k cp $1 $(k get pod -o=jsonpath='{.items[0].metadata.name}' -l app=evergreen-server):/app
}

# useful aliases for the below commands
alias cel="cd $PATH_TO_EVERGREEN; watchmedo auto-restart --directory=./ --pattern='*.py' --recursive -- celery -A celery_app worker --loglevel=INFO --pool solo"
alias celall="cel --queues=notif,slack_interactivity,celery,critical_long_jobs,critical_extra_long_jobs,critical_short_jobs,event_jobs,integration_sync_jobs"

export DD_TRACE_ENABLED=false

# get the node group of pods
# assume zsh
nodegroup() {
  local pods=$(k get pods $@ -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.nodeName}{"\n"}{end}')
  while IFS=' ' read -r line; do
    echo $line
    local arr=($line)
    local node=${arr[1]}
    kubectl get nodes $node -o jsonpath='{.metadata.labels}' | jq '."eks.amazonaws.com/nodegroup"' -C
    kubectl get nodes $node -o jsonpath='{.metadata.labels}' | jq '."alpha.eksctl.io/nodegroup-name"' -C;
  done <<< $pods
}

nodepods ()
{
    if [[ $# -lt 1 ]]; then
        echo "must provide a selection label"
        echo "example: -l alpha.eksctl.io/nodegroup-name=ng-product-private"
        return 1  
    fi
    local nodes=$(k get nodes $@ -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

    RED='\033[0;31m'
    NC='\033[0m' # No Color

    while IFS=' ' read -r line; do
        printf "${RED}${line}${NC}\n"
        local arr=($line);
        local node=${arr[0]};
        kubectl get pods -A --field-selector spec.nodeName=${node}
    done <<< $nodes
}

kall () 
{
  for i in $(kubectl api-resources --verbs=list -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    
    kubectl get --ignore-not-found ${i} "$@"
  done
}


pshell() {
  [[ $# > 0 ]] && export MYSQL_DATABASE=$1
  python shell.py --email=xiong@ziphq.com
}


stay_up() {
  while true
  do
    sudo pmset -a womp 1
    echo "sleep 60 seconds"
    sleep 60
  done
}


alias spods="k get pods -l app=evergreen-server -o=jsonpath='{.items[*].metadata.name}'"
alias ipytest='pytest --pdbcls=IPython.terminal.debugger:TerminalPdb -s --log-cli-level=INFO'

sel() {
  [[ $# -ne 2 ]] && echo "Input should be (row, col)" && return 1
  gsed -n "${1}p" | tr -s ' ' | cut -d' ' -f$2 | tr -d '\n' | pbcopy 
}

alias es='~/code/career/tutorials/wails-example/build/bin/wails-example.app/Contents/MacOS/wails-example'

function sso_if_needed() {
  local session_file="$HOME/.aws/sso/cache/56e5c04e06ab232adbb5819c9e0c2260badd955c.json"
  local expires_at=$(cat ${session_file} | jq '.expiresAt')
  # Convert ISO 8601 to epoch seconds
  target_epoch=$(gdate -d ${expires_at//\"/} +%s)
  now_epoch=$(gdate +%s)
  if (( now_epoch > target_epoch )); then 
    echo "sso cache is expired"
    aws sso login
  else 
    echo "sso cache is valid"
  fi
}

function sshdevbox {
  sso_if_needed

  hostname=$(grep "Host devbox" ~/.ssh/config -A 1 | grep HostName | cut -d ' ' -f4)
  echo "hostname: $hostname"
  if [[ $hostname =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    local ec2_state=$(aws ec2 describe-instances  --filters "Name=ip-address,Values=$hostname" --query 'Reservations[*].Instances[*].State.Name' --profile devbox --output text)
  else
    local ec2_state=$(aws ec2 describe-instances --instance-ids $hostname --profile devbox --query 'Reservations[*].Instances[*].State.Name' --output text)
  fi
  echo "EC2 state: ${ec2_state}"
  [[ $ec2_state != "running" ]] && ~/code/evergreen/website/bin/devbox-boot

  cpsso
  ~/code/evergreen/website/bin/devbox-ssh
}

function cpsso() {
  sso_if_needed
  
  local session_file="$HOME/.aws/sso/cache/56e5c04e06ab232adbb5819c9e0c2260badd955c.json"
  scp $session_file devbox:/home/admin/.aws/sso/cache/
}

########### end zip specific ########### 

alias cd.='cd ..'
alias cd..='cd ../..'
alias cd...='cd ../../..'
alias ll='ls -ltrah --color=auto'
# see https://unix.stackexchange.com/questions/25327/watch-command-alias-expansion
alias watch='watch '

#alias vbr='vim ~/.zshrc'
#alias sbr='source ~/.zshrc'
alias vbr='vim ~/.bashrc'
alias sbr='source ~/.bashrc'

alias ke='kubectl exec -it'
alias de='docker exec -it'

alias vim='nvim'

alias git_branch_clean='git branch --merged | egrep -v "(^\*|master|qa|prod)" | gxargs git branch -d'

export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

clean_disk() {
  # Follow this post https://www.reddit.com/r/mac/comments/1c3ldoi/wheres_my_disk_space_what_is_taking_up_all_the/

  brew cleanup -s
  brew cleanup --prune=all
  # or
  # rm -rf $HOME/Library/Caches/Homebrew/downloads

  go clean -modcache
  rm -rf $HOME/Library/Caches/go-build
  
  rm -rf $HOME/.m2/repository/
  rm -rf $HOME/.gradle/
  rm -rf $HOME/Library/Caches/JetBrains/


  rm -rf $HOME/.cargo/git
  rm -rf $HOME/.cargo/registry

  rm -rf $HOME/.npm
  rm -rf $HOME/Library/Caches/Yarn

  rm -rf $HOME/Library/Application\ Support/Code/User/workspaceStorage/

  # Python
  pip cache purge 
  # or 
  # rm -rf $HOME/Library/Caches/pip


  docker system prune -a --volumes -f
  # Also, need go to Docker Desktop configuration to change virtual disk limit.
}

# ---- Java begin ------
# See post https://dingxiong.github.io/posts/java-getting-started/
if [[ -z $TMUX ]]; then
  export JAVA_HOME=/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home/
fi
# ---- Java end ------

remote_to_ssh() {
  git remote set-url  $(git remote -v | head -1 | sed 's/ (fetch)// ; s/ (push)// ; s;https://github.com/;git@github.com:;')
}
[[ -f $HOME/.cargo/env ]] && source "$HOME/.cargo/env"



# Function to check all branches for merged PRs and delete them (except protected branches)
# Usage: clean_merged_branch
clean_merged_branch() {
    local RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
    local PROTECTED_BRANCHES=("master" "main" "prod" "production" "qa" "dev" "develop" "staging")
    
    echo -e "${BLUE}[INFO]${NC} Checking all branches except protected ones..."
    local branches=$(git branch --format='%(refname:short)' | grep -v '^*')
    local checked=0 deleted=0
    
    for branch in $branches; do
        local is_protected=false
        for protected in "${PROTECTED_BRANCHES[@]}"; do
            if [ "$branch" = "$protected" ]; then
                is_protected=true
                break
            fi
        done
        
        if [ "$is_protected" = false ]; then
            echo -e "\n${BLUE}=== Checking branch: $branch ===${NC}"
            if _clean_single_branch "$branch"; then
                ((deleted++))
            fi
            ((checked++))
        else
            echo -e "${YELLOW}[SKIP]${NC} Skipping protected branch: $branch"
        fi
    done
    
    echo -e "\n${GREEN}[SUMMARY]${NC} Checked $checked branches, deleted $deleted branches"
}

# Helper function to clean a single branch
_clean_single_branch() {
    local BRANCH_NAME="$1"
    local RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
    
    echo -e "${BLUE}[INFO]${NC} Checking branch: $BRANCH_NAME"
    
    
    # Check gh authentication
    if ! gh auth status &>/dev/null; then
        echo -e "${RED}[ERROR]${NC} GitHub CLI not authenticated. Please run: gh auth login"
        return 1
    fi
    
    # Find PR for the branch
    local PR_INFO=$(gh pr list --head "$BRANCH_NAME" --state all --json number,title,state --limit 1 2>/dev/null)
    
    if [ -z "$PR_INFO" ] || [ "$PR_INFO" = "[]" ]; then
        echo -e "${YELLOW}[WARNING]${NC} No PR found for branch '$BRANCH_NAME'"
        return 0
    fi
    
    # Extract PR details
    local PR_NUMBER=$(echo "$PR_INFO" | jq -r '.[0].number')
    local PR_TITLE=$(echo "$PR_INFO" | jq -r '.[0].title')
    local PR_STATE=$(echo "$PR_INFO" | jq -r '.[0].state')
    
    echo -e "${GREEN}[SUCCESS]${NC} Found PR #$PR_NUMBER: $PR_TITLE (State: $PR_STATE)"
    
    # Check if PR is in master history
    local CURRENT_BRANCH=$(git branch --show-current)
    local MAIN_BRANCH="master"
    
    # Try to determine the main branch
    if git show-ref --verify --quiet refs/heads/main; then
        MAIN_BRANCH="main"
    fi
    
    git checkout "$MAIN_BRANCH" &>/dev/null && git pull origin "$MAIN_BRANCH" &>/dev/null
    
    if git log --oneline --grep="#$PR_NUMBER" | grep -q "#$PR_NUMBER"; then
        echo -e "${GREEN}[SUCCESS]${NC} PR #$PR_NUMBER found in $MAIN_BRANCH branch history"
        
        # Switch away from branch if we're on it
        [ "$(git branch --show-current)" = "$BRANCH_NAME" ] && git checkout "$MAIN_BRANCH" &>/dev/null
        
        # Ask for confirmation before deleting
        echo -e "${YELLOW}[CONFIRM]${NC} Delete branch '$BRANCH_NAME'? (y/N): "
        read -r confirmation
        
        if [[ "$confirmation" =~ ^[Yy]$ ]]; then
            # Delete local branch only
            if git branch -D "$BRANCH_NAME" &>/dev/null; then
                echo -e "${GREEN}[SUCCESS]${NC} Deleted local branch '$BRANCH_NAME'"
                
                # Switch back to original branch if it still exists and wasn't the target
                [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ] && [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ] && \
                    git show-ref --verify --quiet "refs/heads/$CURRENT_BRANCH" && git checkout "$CURRENT_BRANCH" &>/dev/null
                
                return 0  # Successfully deleted
            else
                echo -e "${RED}[ERROR]${NC} Failed to delete local branch '$BRANCH_NAME'"
                return 1
            fi
        else
            echo -e "${BLUE}[INFO]${NC} Branch '$BRANCH_NAME' was not deleted"
            # Switch back to original branch
            [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ] && \
                git show-ref --verify --quiet "refs/heads/$CURRENT_BRANCH" && git checkout "$CURRENT_BRANCH" &>/dev/null
            return 1
        fi
    else
        echo -e "${YELLOW}[WARNING]${NC} PR #$PR_NUMBER not found in $MAIN_BRANCH history - branch not deleted"
        # Switch back to original branch
        [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ] && \
            git show-ref --verify --quiet "refs/heads/$CURRENT_BRANCH" && git checkout "$CURRENT_BRANCH" &>/dev/null
        return 1
    fi
}

