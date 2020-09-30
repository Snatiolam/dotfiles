autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

alias ll='ls -l'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd../../..'

bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

