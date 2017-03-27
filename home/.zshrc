# username is not shown for default user in command prompt
DEFAULT_USER=rz
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
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir)
    # this is what's shown on the right
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(virtualenv vcs background_jobs)
fi

# load following plugins
plugins=(git)

# User configuration
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# configure FZF
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# aliases
alias ":q"="exit"
alias ":qa"="exit"

# added by travis gem
[ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

