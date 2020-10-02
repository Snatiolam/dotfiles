autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

HISTSIZE=5000
HISTFILE=~/.cache/zsh/history
SAVEHIST=5000

alias ls='ls --color=auto'
alias ll='ls -l'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd../../..'

# <Ctrl-v> To escape know the wanted key to map
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char

# neofetch
