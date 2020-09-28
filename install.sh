#!/bin/bash


ROOT_DIR="."
INSTALL_DIR="$HOME"

install_binaries(){
    echo "Installing shell scripts in ~/.local/bin"
    INSTALL_BIN="$INSTALL_DIR/.local/bin"
    [ ! -d "$INSTALL_BIN" ] && mkdir -p "$INSTALL_BIN"
    for file in "$ROOT_DIR/.local/bin/*"
    do
        sudo cp $file $INSTALL_BIN
    done
    echo "Shell scripts installed"
}

install_vimrc(){
    echo "Installing vimrc file"
    cp .vimrc $HOME
    echo "Installed vimrc"
}

install_i3_config(){
    [ ! -d "$INSTALL_DIR/.config/i3" ] && sudo mkdir -p "$INSTALL_DIR/.config/i3"
    cp "$ROOT_DIR/.config/i3/config" "$INSTALL_DIR/.config/i3"
}

install_i3blocks_config(){
    [ ! -d "$INSTALL_DIR/.config/i3blocks" ] && mkdir -p "$INSTALL_DIR/.config/i3blocks"
    cp "$ROOT_DIR/.config/i3blocks/config" "$INSTALL_DIR/.config/i3blocks/"
    INSTALL_SCRIPTS="$ROOT_DIR/.config/i3blocks/scripts"
    [ ! -d "$INSTALL_DIR/.config/i3blocks/scripts" ] && sudo mkdir -p "$INSTALL_DIR/.config/i3blocks/scripts"
    for file in "$INSTALL_SCRIPTS/*"
    do
        sudo cp $file "$INSTALL_DIR/.config/i3blocks/scripts"
    done
    
}

main(){
    # install_binaries
    # install_vimrc
    # install_i3_config
    install_i3blocks_config
}

main

exit 0
