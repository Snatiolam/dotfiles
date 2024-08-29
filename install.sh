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
    echo "Installing vimrc file"
    cp .vimrc "$HOME/"
    echo "Installed vimrc"
}

install_zsh_files(){
    ZSHRC="$HOME/.zshrc"
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
        echo "File does not exist"
        ln -s $(realpath "$ROOT_DIR/.zshrc") "$ZSHRC"
        # cp "$ROOT_DIR/.zprofile" "$HOME/"
    fi
}
main(){
    # install_binaries
    # install_vimrc
    install_zsh_files
}

main

exit 0
