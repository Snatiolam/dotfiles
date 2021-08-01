# History cache 
HISTSIZE=5000
HISTFILE=~/.cache/zsh/history
SAVEHIST=5000

# Zsh tab completion
autoload -U compinit
zstyle ":completion:*" menu select
zmodload zsh/complist
compinit

#Zsh git version control system info for prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats 'on branch %b ' # Format vcs_info_msg_0_ variable

# Colors to basic commands
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
# Basic aliases
alias ll='ls -l'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd../../..'
# Verbosity and safer options
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -vI'

# <Ctrl-v> To escape know the wanted key to map
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^R' history-incremental-search-backward
bindkey '^U' kill-whole-line
# bindkey -e # for debug

# autoload -U promptinit
# promptinit
# # prompt -l
# prompt fade

autoload -U colors && colors
setopt PROMPT_SUBST   # When single quote let expand the prompt
PS1='%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~ %{$fg_bold[red]%}$vcs_info_msg_0_%{$fg[red]%}]%{$reset_color%}$%b '

# neofetch

## PLugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[alias]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[path]='none'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[globbing]='none'

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#000,bg=#777,bold,underline"
