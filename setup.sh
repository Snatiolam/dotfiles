#!/bin/bash


ROOT_DIR="."
INSTALL_DIR="$HOME"

install_binaries(){
    echo "Installing shell scripts in ~/.local/bin"
    INSTALL_BIN="$INSTALL_DIR/.local/bin"
    [ ! -d "$INSTALL_BIN" ] && mkdir -p "$INSTALL_BIN"
    for file in "$ROOT_DIR/.local/bin/*"
    do
        sudo cp $file "$INSTALL_BIN/"
    done
    echo "Shell scripts installed"
}

setup_vim(){
    echo "Installing VIM configuration files"
    FILE="$HOME/.vimrc"
    if [ -f "$FILE" ]; then
        echo "File $FILE exist"
        read -p "Do you want to overwrite it? Y/N -> " -n 1 -r
        if [[ "$REPLY" =~ ^[Yy]$ ]]
        then
            printf "\nFile is going to be replaced"
            cp .vimrc "$FILE"
        fi
        printf "\n"
    else
        echo "File $FILE does not exist."
        cp .vimrc "$FILE"
    fi

    if [ -f ~/.vim/autoload/plug.vim ]; then
        echo "Vim Plug is already installed."
    else
        echo "Vim Plug is not installed. Installing Vim Plug plugin."
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

}

setup_nvim() {
    if [ -d "$HOME/.config/nvim" ]; then
        echo "Neovim conf already exists. Deleting old Neovim config"
        rm -rf $HOME/.config/nvim
        install_nvim_files
    else
        echo "Neovim config does not exist"
        install_nvim_files
    fi
}

install_nvim_files() {
    echo "Installing Neovim config"
    mkdir -p $HOME/.config/nvim

    cp .config/nvim/init.lua $HOME/.config/nvim/
    cp -r .config/nvim/lua $HOME/.config/nvim/

    # curl fails is uncommented
    # PATH="${XDG_DATA_HOME:-$HOME/.local/share}";
    #
     if [ -d ~/.fzf ]; then
         echo "FZF is already installed"
     else
         echo "FZF is not installed. Installing FZF"
         git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
     fi

     if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim ]; then
         echo "Vim Plug is already installed"
     else
         echo "Vim Plug is not installed. Installing Vim Plug"
         curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
     fi
}

setup_zsh(){
    ZSHRC="$HOME/.zshrc"
    echo "Installing ZSH configuration files"
    if [ -f "$ZSHRC" ]; then
        echo "File $ZSHRC exist"
        read -p "Do you want to overwrite it? Y/N -> " -n 1 -r
        if [[ "$REPLY" =~ ^[Yy]$ ]]
        then
            printf "\nFile is going to be replaced"
            rm $ZSHRC
            ln -s $(realpath "$ROOT_DIR/.zshrc") "$ZSHRC"
            # cp "$ROOT_DIR/.zprofile" "$HOME/"
        fi
        printf "\n"
    else
        echo "File $ZSHRC does not exist"
        ln -s $(realpath "$ROOT_DIR/.zshrc") "$ZSHRC"
        # cp "$ROOT_DIR/.zprofile" "$HOME/"
    fi

    mkdir -p ~/.cache/zsh

    if [ -d ~/.zsh/zsh-autosuggestions ]; then
        echo "zsh-autosuggestions plugin is already installed."
    else
        echo "zsh-autosuggestions plugin is not installed. Installing zsh-autosuggestions plugin."
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    fi

    if [ -d ~/.zsh/zsh-syntax-highlighting ]; then
        echo "zsh-syntax-highlighting plugin is already installed."
    else
        echo "zsh-syntax-highlighting plugin is not installed. Installing zsh-syntax-highlighting plugin."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
    fi
}

main(){
    # install_binaries
    setup_nvim
    setup_vim
    setup_zsh
}

main

exit 0
