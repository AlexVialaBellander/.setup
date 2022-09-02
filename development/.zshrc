# From IvanUkhov/.development
# Helper functions
function has {
  if type "${1}" > /dev/null; then
    return 0
  else
    return 1
  fi
}

function is {
  if [[ "$(echo $(uname) | tr '[:upper:]' '[:lower:]')" == "${1}" ]]; then
    return 0
  else
    return 1
  fi
}

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git web-search zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/alexandervialabellander/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/alexandervialabellander/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/alexandervialabellander/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/alexandervialabellander/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

alias atk="() {python -m ipykernel install --user --name=$1}"
alias setup="cd ~/.setup"

# From IvanUkhov/.development
# Git aliases
if has git; then
  alias g=git
  alias ga='git add'
  alias gap='git add --patch'
  alias gb='git branch'
  alias gc='git commit'
  alias gca='git commit --amend'
  alias gco='git checkout'
  alias gd='git diff'
  alias gds='git diff --staged'
  alias gg='git grep --line-number'
  alias gl='git log'
  alias gp='git push'
  alias gpl='git pull'
  alias gs='git status'
fi


