#!/bin/bash


BIN_DIR="./.local/bin"
BIN_INSTALL="$HOME/.local/bin"

install_binaries(){
    [ ! -d "$BIN_INSTALL" ] && mkdir -p $BIN_INSTALL
    for file in "$BIN_DIR/*"
    do
        cp $file $BIN_INSTALL
    done
}

install_binaries
exit 0
