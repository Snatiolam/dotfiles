#!/bin/bash

set -euo pipefail

INSTALL_DIR="$HOME"

die() {
    echo "Error: $1" >&2
    exit 1
}

check_command() {
    command -v "$1" >/dev/null 2>&1 || die "$1 is required but not installed"
}

install_binaries(){
    echo "Installing shell scripts in ~/.local/bin"
    INSTALL_BIN="$INSTALL_DIR/.local/bin"
    [ ! -d "$INSTALL_BIN" ] && mkdir -p "$INSTALL_BIN"
    for file in .local/bin/*
    do
        cp -f "$file" "$INSTALL_BIN/"
    done
    echo "Shell scripts installed"
}

install_fonts() {
    check_command wget
    check_command unzip

    echo "Installing fonts UbuntuMono and Monaspice Nerd Fonts"
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1"
    wget -P "$FONT_DIR" "$font_url/UbuntuMono.zip" || die "Failed to download UbuntuMono fonts"
    unzip -n "$FONT_DIR/UbuntuMono.zip" -d "$FONT_DIR" || die "Failed to extract UbuntuMono fonts"
    rm "$FONT_DIR/UbuntuMono.zip"

    wget -P "$FONT_DIR" "$font_url/Monaspace.zip" || die "Failed to download Monaspace fonts"
    unzip -n "$FONT_DIR/Monaspace.zip" -d "$FONT_DIR" || die "Failed to extract Monaspace fonts"
    rm "$FONT_DIR/Monaspace.zip"

    fc-cache -f "$FONT_DIR" || die "Failed to refresh font cache"
    echo "Fonts installed successfully"
}

setup_tmux() {
    echo "Installing TMUX configuration files"
    FILE="$HOME"/.tmux.conf
    if [ -f "$FILE" ]; then
        echo "File $FILE exist"
        read -p "Do you want to overwrite it? Y/N -> " -n 1 -r
        if [[ "$REPLY" =~ ^[Yy]$ ]]
        then
            printf "\nFile is going to be replaced"
            cp .tmux.conf "$FILE"
        fi
        printf "\n"
    else
        echo "File $FILE does not exist. Installing..."
        cp .tmux.conf "$FILE"
    fi
}

setup_vim() {
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
        echo "File $FILE does not exist. Installing..."
        cp .vimrc "$FILE"
    fi

    if [ -f ~/.vim/autoload/plug.vim ]; then
        echo "Vim Plug is already installed."
    else
        echo "Vim Plug is not installed. Installing Vim Plug plugin."
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
            || die "Failed to install vim-plug"
    fi

}

setup_nvim() {
    if [ -d "$HOME/.config/nvim" ]; then
        echo "Neovim conf already exists. Deleting old Neovim config"
        rm -rf "$HOME/.config/nvim"
        install_nvim_files
    else
        echo "Neovim config does not exist. Installing..."
        install_nvim_files
    fi
}

install_nvim_files() {
    echo "Installing Neovim config"
    mkdir -p "$HOME/.config/nvim"

    cp .config/nvim/init.lua "$HOME/.config/nvim/" || die "Failed to copy nvim init.lua"
    cp -r .config/nvim/lua "$HOME/.config/nvim/" || die "Failed to copy nvim lua directory"
    cp -r .config/nvim/ftplugin "$HOME/.config/nvim/" || die "Failed to copy ftplugin directory"

    if [ -d ~/.fzf ]; then
        echo "FZF is already installed"
    else
        echo "FZF is not installed. Installing FZF"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
            || die "Failed to clone fzf"
    fi

    if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim ]; then
        echo "Vim Plug is already installed"
    else
        echo "Vim Plug is not installed. Installing Vim Plug"
        curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
            || die "Failed to install vim-plug for neovim"
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
            rm "$ZSHRC"
            cp .zshrc "$ZSHRC"
        fi
        printf "\n"
    else
        echo "File $ZSHRC does not exist. Installing..."
        cp .zshrc "$ZSHRC"
    fi

    mkdir -p ~/.cache/zsh

    if [ -d ~/.zsh/zsh-autosuggestions ]; then
        echo "zsh-autosuggestions plugin is already installed."
    else
        echo "zsh-autosuggestions plugin is not installed. Installing zsh-autosuggestions plugin."
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions \
            || die "Failed to clone zsh-autosuggestions"
    fi

    if [ -d ~/.zsh/zsh-syntax-highlighting ]; then
        echo "zsh-syntax-highlighting plugin is already installed."
    else
        echo "zsh-syntax-highlighting plugin is not installed. Installing zsh-syntax-highlighting plugin."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting \
            || die "Failed to clone zsh-syntax-highlighting"
    fi
}

install_config_dir() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [ -d "$dest" ]; then
        echo "$name config already exists at $dest"
        read -p "Do you want to recreate it? (current config will be deleted) Y/N -> " -r
        printf "\n"
        if [[ ! "$REPLY" =~ ^[Yy]$ ]]
        then
            echo "Skipping $name config"
            return
        fi
        echo "Recreating $name config"
        rm -rf "$dest" || die "Failed to remove $dest"
    else
        echo "$name config does not exist. Installing..."
    fi

    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest" || die "Failed to copy $name config"
    echo "$name config installed"
}

setup_hypr() {
    install_config_dir ".config/hypr" "$HOME/.config/hypr" "Hyprland"
}

setup_quickshell() {
    install_config_dir ".config/quickshell" "$HOME/.config/quickshell" "Quickshell"
}

setup_hypr_stack() {
    setup_quickshell
    setup_hypr
}

install_sddm_package() {
    if command -v sddm &>/dev/null; then
        echo "SDDM is already installed"
        return
    fi

    if command -v pacman &>/dev/null; then
        sudo pacman -S --needed --noconfirm sddm || die "Failed to install SDDM"
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y sddm || die "Failed to install SDDM"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y sddm || die "Failed to install SDDM"
    else
        die "Unsupported package manager. Install SDDM manually."
    fi
}

setup_sddm() {
    check_command sudo
    check_command systemctl
    check_command tee

    install_sddm_package

    echo "Installing Catppuccin Macchiato SDDM theme"
    local theme_dir="/usr/share/sddm/themes/catppuccin-macchiato"
    sudo mkdir -p "$theme_dir" || die "Failed to create theme directory"
    sudo cp -f .config/sddm/macchiato/* "$theme_dir/" || die "Failed to copy theme files"
    sudo cp -f .config/hypr/cat-waves.png "$theme_dir/" || die "Failed to copy wallpaper"

    # The greeter runs as root and cannot read user fonts, so make them system-wide
    local font_glob=~/.local/share/fonts/Monaspice*
    if compgen -G "$font_glob" >/dev/null; then
        echo "Installing Monaspice Nerd Font system-wide for the greeter"
        sudo mkdir -p /usr/local/share/fonts/MonaspiceNerdFont
        sudo cp -f $font_glob /usr/local/share/fonts/MonaspiceNerdFont/
        sudo fc-cache -f /usr/local/share/fonts >/dev/null || die "Failed to refresh system font cache"
    else
        echo "WARNING: Monaspice Nerd Font not found in ~/.local/share/fonts, the theme will fall back to the default font."
    fi

    echo "Writing SDDM configuration"
    sudo mkdir -p /etc/sddm.conf.d || die "Failed to create SDDM config directory"

    # SDDM reads EVERY file inside /etc/sddm.conf.d (ConfigBase::load() uses
    # QDir::Files with no *.conf filter), so leftover configs that point at an
    # old theme/ThemeDir must be moved OUT of the directory, not renamed. A
    # ThemeDir inside a 700 home dir is also unreadable by the greeter user,
    # which makes SDDM fall back to its built-in theme.
    local backup_dir="/etc/sddm.conf.d.disabled"
    for f in /etc/sddm.conf.d/*; do
        [ -f "$f" ] || continue
        [ "$(basename "$f")" = "10-catppuccin.conf" ] && continue
        if grep -qE "^(Current|ThemeDir)=" "$f" 2>/dev/null; then
            echo "Moving conflicting config out of the way: $f"
            sudo mkdir -p "$backup_dir"
            sudo mv "$f" "$backup_dir/" || die "Failed to move $f"
        fi
    done

    sudo tee /etc/sddm.conf.d/10-catppuccin.conf >/dev/null <<'EOF'
[Theme]
ThemeDir=/usr/share/sddm/themes
Current=catppuccin-macchiato
EOF
    # SDDM does not read ~/.config/sddm/sddm.conf, but a stale copy is a common
    # source of confusion while debugging the greeter.
    if [ -f "$HOME/.config/sddm/sddm.conf" ]; then
        echo "Moving unused user config aside: $HOME/.config/sddm/sddm.conf"
        mv "$HOME/.config/sddm/sddm.conf" "$HOME/.config/sddm/sddm.conf.bak"
    fi

    if [ -f /etc/sddm.conf ] && grep -q "^Current=" /etc/sddm.conf; then
        echo "NOTE: /etc/sddm.conf sets Current= and may override the theme."
    fi
    [ -f /etc/sddm.conf ] && ! grep -q "^Current=" /etc/sddm.conf && \
        echo "NOTE: /etc/sddm.conf exists, it may override the theme."

    echo "Enabling SDDM as display manager"
    sudo systemctl enable sddm || die "Failed to enable SDDM"
    for dm in lightdm gdm gdm3 lxdm slim xdm; do
        if systemctl is-enabled --quiet "$dm" 2>/dev/null; then
            echo "Disabling $dm to avoid conflicts..."
            sudo systemctl disable "$dm" || die "Failed to disable $dm"
        fi
    done

    echo "SDDM setup complete"
}

show_help() {
    echo "Usage: ./setup.sh [options]"
    echo ""
    echo "Options:"
    echo "  -a, --all       Install everything"
    echo "  -n, --nvim      Setup Neovim"
    echo "  -z, --zsh       Setup ZSH"
    echo "  -t, --tmux      Setup TMUX"
    echo "  -v, --vim       Setup VIM"
    echo "  -f, --fonts     Install Fonts"
    echo "  -b, --bin       Install Binaries"
    echo "  -g, --git       Setup Git config"
    echo "  -H, --hypr      Setup Hyprland + Quickshell"
    echo "  -s, --sddm      Install SDDM + Catppuccin Macchiato theme"
    echo "  -h, --help      Show this help message"
}

main(){
    if [ $# -eq 0 ]; then
        echo "No arguments provided. Starting interactive mode..."

        read -p "Install Neovim config? (y/n): " nvim_res
        [[ "$nvim_res" =~ ^[Yy]$ ]] && setup_nvim

        read -p "Install ZSH config? (y/n): " zsh_res
        [[ "$zsh_res" =~ ^[Yy]$ ]] && setup_zsh

        read -p "Install Fonts? (y/n): " font_res
        [[ "$font_res" =~ ^[Yy]$ ]] && install_fonts

        read -p "Install Hyprland + Quickshell config? (y/n): " hypr_res
        [[ "$hypr_res" =~ ^[Yy]$ ]] && setup_hypr_stack

        read -p "Install SDDM + Catppuccin Macchiato theme? (y/n): " sddm_res
        [[ "$sddm_res" =~ ^[Yy]$ ]] && setup_sddm

        return
    fi

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                install_binaries; install_fonts; setup_tmux; setup_nvim; setup_zsh; setup_hypr_stack; setup_sddm
                shift ;;
            -n|--nvim)
                setup_nvim; shift ;;
            -z|--zsh)
                setup_zsh; shift ;;
            -t|--tmux)
                setup_tmux; shift ;;
            -v|--vim)
                setup_vim; shift ;;
            -f|--fonts)
                install_fonts; shift ;;
            -b|--bin)
                install_binaries; shift ;;
            -H|--hypr)
                setup_hypr_stack; shift ;;
            -s|--sddm)
                setup_sddm; shift ;;
            -g|--git)
                ln -s $(realpath ./.gitconfig) ~/ ; shift ;;
            --firefox)
                sudo ln -s $(realpath ./firefox/policies.json) /usr/lib64/firefox/distribution/policies.json; shift ;;
            -h|--help)
                show_help; exit 0 ;;
            *)
                echo "Unknown option: $1"
                show_help; exit 1 ;;
        esac
    done
}

main $@

exit 0
