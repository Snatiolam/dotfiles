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

install_vimrc(){
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
}

install_zsh_files(){
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
    install_vimrc
    install_zsh_files
}

main

exit 0
