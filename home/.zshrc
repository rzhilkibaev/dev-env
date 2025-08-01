# username is not shown for default user in command prompt
DEFAULT_USER=$USER
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# make fonts work correctly in tmux
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# use nvim for command line editing (Ctrl+x, Ctrl+e in terminal)
export EDITOR=nvim

# Set name of the theme to load.
if [ -d $ZSH/custom/themes/powerlevel9k ]; then
    ZSH_THEME=powerlevel9k/powerlevel9k
    # this is what's shown on the left
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status context dir)
    # this is what's shown on the right
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(background_jobs)
fi

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
# load following plugins
plugins=()

# User configuration
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# configure FZF
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# aliases
# vim-like exit
alias ":q"="exit"
alias ":qa"="exit"
# vim-like nvim
alias "vim"="nvim"
# easy virtualenv
alias "venv"="source ./venv/bin/activate"
# ls
alias "ll"="eza --long --header --all --group-directories-first"
alias "tree"="eza --tree --all"
alias "http"="http --body"

# disable *.pyc files
export PYTHONDONTWRITEBYTECODE=true

autoload -U +X bashcompinit && bashcompinit

for rc in ~/.zshrc.d/*; do source $rc; done

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
#true at the end makes the script exit with 0 instead of 1 if the directory is not found
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh" || true

