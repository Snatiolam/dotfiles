# History cache
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Zsh tab completion
autoload -U compinit
zstyle ":completion:*" matcher-list 'm:{a-z}={A-Za-z}'
zstyle ":completion:*" menu select
zmodload zsh/complist
compinit

#Zsh git version control system info for prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats $'\Uf126 %b ' # Format vcs_info_msg_0_ variable

alias cdf='cd $(find * -type d | fzf)'

# Aliases

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ll='ls -l'

# Verbosity and safer options
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -vI'

# <Ctrl-v> To escape and know the wanted key to map
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char

# bindkey -e # for debug

# autoload -U promptinit
# promptinit
# # prompt -l
# prompt fade

autoload -U colors && colors
setopt PROMPT_SUBST   # When single quote let expand the prompt
# PS1='%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~ %{$fg_bold[red]%}$vcs_info_msg_0_%{$fg[red]%}]%{$reset_color%}$%b '
# PS1='%B%F{red}[%F{yellow}%n%F{green}@%F{blue}%M %F{magenta}%~ %{$fg_bold[red]%}$vcs_info_msg_0_%F{red}]%F{reset_colors}$%b '
PS1='%B%F{yellow}%n%F{green}@%F{blue}%M %F{magenta}%~ %{$fg_bold[red]%}$vcs_info_msg_0_%F{reset_colors}$%b '

# neofetch

## PLugins
 source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
 ZSH_HIGHLIGHT_STYLES[alias]='fg=yellow,bold'
 ZSH_HIGHLIGHT_STYLES[path]='fg=magenta'
 ZSH_HIGHLIGHT_STYLES[precommand]='fg=green,bold'
 ZSH_HIGHLIGHT_STYLES[globbing]='none'
 ZSH_HIGHLIGHT_STYLES[redirection]='fg=cyan'
 ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=cyan'
 ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=magenta'
 ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta'

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#000,bg=#777,bold,underline"

# . "$HOME/.asdf/asdf.sh"
# . "$HOME/.asdf/plugins/java/set-java-home.zsh"

export PATH=$PATH:/home/snatiolam/.local/share/eclipse-jdtls/bin
export PATH=$PATH:"$HOME/.cargo/bin"
export PATH=$PATH:/opt/gradle/gradle-8.10/bin
export PATH=$PATH:"$HOME/.local/bin"
