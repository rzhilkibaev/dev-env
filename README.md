dev-env
=======

!macOS only!

## Usage
`./install PACKAGE...`

## Tools
alacritty
oh-my-zsh
tmux
nvim
fzf
ag
pack (pack/unpack)

## Directory structure
```
root
├── install # main script
└── packages # directory with installable packages
    └── <package_name>
        └── install # package installation script
```
