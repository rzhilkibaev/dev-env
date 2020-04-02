# username is not shown for default user in command prompt
DEFAULT_USER=$USER
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# use nvim for command line editing (Ctrl+x, Ctrl+e in terminal)
export EDITOR=nvim
# enable more colors in terminal
export TERM=xterm-256color

# Set name of the theme to load.
if [ -d $ZSH/custom/themes/powerlevel9k ]; then
    ZSH_THEME=powerlevel9k/powerlevel9k
    # this is what's shown on the left
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status context dir)
    # this is what's shown on the right
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(virtualenv vcs background_jobs)
fi

# Start tmux when starting zsh
ZSH_TMUX_AUTOSTART=false
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
# load following plugins
plugins=(git tmux zsh-syntax-highlighting)

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
# easy virtualenv
alias "venv"="source ./venv/bin/activate"
alias "goo"="googler"

# disable *.pyc files
export PYTHONDONTWRITEBYTECODE=true

# added by travis gem
[ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting


autoload -U +X bashcompinit && bashcompinit
complete -C /usr/local/bin/terraform terraform

export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

for rc in ~/.zshrc.d/*; do source $rc; done

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
