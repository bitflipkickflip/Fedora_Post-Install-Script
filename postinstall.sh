#!/bin/bash
# ==============================================================================
# Fedora Post-Installation Configurator
# ==============================================================================

# bash options used: 
# -u treats unset variables as an error
# -o pipefail catches non-zero exit codes in any part of a pipeline
set -uo pipefail

# --- Display & Logging ---
readonly C_BLUE='\033[0;34m'
readonly C_GREEN='\033[0;32m'
readonly C_YELLOW='\033[1;33m'
readonly C_RESET='\033[0m'

log_info() { echo -e "${C_BLUE}[*] $1${C_RESET}"; }
log_success() { echo -e "${C_GREEN}[+] $1${C_RESET}"; }
log_warn() { echo -e "${C_YELLOW}[!] $1${C_RESET}"; }

# --- State Management ---
# Ordered array ensures the menu renders in the exact same sequence every time
readonly MENU_KEYS=(
    "WALLPAPER" "STEAM" "BRAVE" "FIREFOX_REMOVE" "NVIDIA" "DISCORD" 
    "PRISM" "JAGEX" "KDE_BLOAT" "SUBLIME" "VLC" "KDENLIVE" 
    "ORCASLICER" "UPGRADE"
)

declare -A OPTS=(
    [WALLPAPER]="1" [STEAM]=true [BRAVE]=true [FIREFOX_REMOVE]=true 
    [NVIDIA]=false [DISCORD]=true [PRISM]=true [JAGEX]=true 
    [KDE_BLOAT]=true [SUBLIME]=true [VLC]=true [KDENLIVE]=true 
    [ORCASLICER]=true [UPGRADE]=true
)

declare -A LABELS=(
    [WALLPAPER]="Wallpaper Setup" [STEAM]="Install Steam" [BRAVE]="Install Brave" 
    [FIREFOX_REMOVE]="Remove Firefox" [NVIDIA]="Install NVIDIA" [DISCORD]="Install Discord" 
    [PRISM]="Install Prism Launcher" [JAGEX]="Install Jagex Launcher" [KDE_BLOAT]="Remove KDE Bloat" 
    [SUBLIME]="Replace KWrite w/ Sublime" [VLC]="Install VLC" [KDENLIVE]="Install Kdenlive" 
    [ORCASLICER]="Install OrcaSlicer" [UPGRADE]="System Upgrade"
)

# ==============================================================================
# INTERACTIVE MENU
# ==============================================================================

render_menu() {
    clear
    echo "========================================================"
    echo "         FEDORA POST-INSTALLATION CONFIGURATOR          "
    echo "========================================================"
    echo " Module / Option                 Current Status         "
    echo "--------------------------------------------------------"
    
    local i=1
    for key in "${MENU_KEYS[@]}"; do
        local display_val="${OPTS[$key]}"
        if [[ "$key" == "WALLPAPER" ]]; then
            [[ "$display_val" == "3" ]] && display_val="Disabled (3)" || display_val="Resolution $display_val"
        fi
        
        # printf options used: %-32s pads the string to exactly 32 characters left-aligned
        printf " %-32s : %s\n" "[$i] ${LABELS[$key]}" "$display_val"
        ((i++))
    done

    echo "========================================================"
    echo " Wallpaper Options (select via #1):"
    echo "   1 = Standard 1440p (2560x1440) [Default]"
    echo "   2 = Ultrawide 1440p (3440x1440)"
    echo "   3 = Skip Wallpaper Setup"
    echo "--------------------------------------------------------"
    echo " Enter module number to toggle (1-${#MENU_KEYS[@]})"
    echo " Type 'run' to execute | Type 'quit' to abort"
    echo "========================================================"
}

handle_input() {
    local index=$1
    if [[ "$index" -ge 1 && "$index" -le "${#MENU_KEYS[@]}" ]]; then
        local key="${MENU_KEYS[$((index-1))]}"
        
        if [[ "$key" == "WALLPAPER" ]]; then
            echo -e "\n1) 2560x1440  |  2) 3440x1440  |  3) Skip"
            read -r -p "Enter choice (1-3): " choice </dev/tty
            if [[ "$choice" =~ ^[1-3]$ ]]; then
                OPTS[$key]="$choice"
            fi
        else
            [[ "${OPTS[$key]}" == true ]] && OPTS[$key]=false || OPTS[$key]=true
        fi
    fi
}

menu_loop() {
    while true; do
        render_menu
        read -r -p "set > " raw_input </dev/tty
        
        # tr options used: -d '\r' deletes carriage returns, '[:upper:]' '[:lower:]' converts to lowercase
        # xargs options used: defaults to echo, effectively stripping leading/trailing whitespace
        local input
        input=$(echo "$raw_input" | tr -d '\r' | tr '[:upper:]' '[:lower:]' | xargs)
        
        if [[ "$input" == "run" || "$input" == "r" ]]; then
            break
        elif [[ "$input" == "quit" || "$input" == "q" ]]; then
            echo "Abort requested. Exiting."
            exit 0
        elif [[ "$input" =~ ^[0-9]+$ ]]; then
            handle_input "$input"
        fi
    done
}

# ==============================================================================
# EXECUTION MODULES
# ==============================================================================

init_sudo_keepalive() {
    log_info "Authenticating sudo and initializing keep-alive daemon..."
    # sudo options used: -v validates the user's credentials and updates the timestamp
    sudo -v
    
    # Background process tied to parent PID ($$) via kill -0 check
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" 2>/dev/null || exit
    done 2>/dev/null &
}

remove_bloat() {
    log_info "Executing KDE Bloatware Removal..."
    local pkgs=(
        kontact kmail korganizer akregator kaddressbook
        kcontacts kaccounts-integration kaccounts-providers
        akonadi-server akonadi-contacts akonadi-calendar
        kdepim-addons akonadiconsole itinerary
        elisa-player dragon kamoso kate khelpcenter kfind konqueror neochat
        kpatience kmines ksudoku kinfocenter kpat kmahjongg
    )

    # dnf options used: remove uninstalls packages, -y answers yes
    sudo dnf remove -y "${pkgs[@]}"
    
    # dnf options used: autoremove strips orphaned dependencies
    sudo dnf autoremove -y

    # find options used: -iname matches case-insensitively, -exec rm -rf {} + executes recursive removal on all found paths
    local patterns=("*kontact*" "*kmail*" "*akonadi*" "*korganizer*" "*elisa*" "*kaccounts*" "*neochat*")
    for pattern in "${patterns[@]}"; do
        find ~/.config ~/.local/share ~/.cache -iname "$pattern" -exec rm -rf {} + 2>/dev/null || true
    done
    log_success "Bloatware removed."
}

manage_browsers() {
    if [[ "${OPTS[FIREFOX_REMOVE]}" == true ]]; then
        log_info "Removing Firefox..."
        sudo dnf remove -y firefox
    fi

    if [[ "${OPTS[BRAVE]}" == true ]]; then
        log_info "Installing Brave Browser..."
        sudo dnf install -y dnf-plugins-core
        # dnf options used: config-manager addrepo --from-repofile pulls external repo config
        sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
        sudo dnf install -y brave-browser
    fi
}

install_nvidia() {
    log_info "Installing NVIDIA Drivers..."
    # dnf options used: config-manager setopt modifies repository properties
    sudo dnf config-manager setopt rpmfusion-nonfree-nvidia-driver.enabled=1
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
}

install_gaming_tools() {
    if [[ "${OPTS[STEAM]}" == true ]]; then
        log_info "Installing Steam..."
        sudo dnf install -y fedora-workstation-repositories
        sudo dnf config-manager setopt rpmfusion-nonfree-steam.enabled=1
        sudo dnf install -y steam
    fi

    if [[ "${OPTS[PRISM]}" == true ]]; then
        log_info "Installing Prism Launcher via Flatpak..."
        sudo dnf install -y flatpak
        # flatpak options used: remote-add registers source repo, --if-not-exists avoids duplicates, --system targets global scope
        sudo flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        sudo flatpak install --system -y flathub org.prismlauncher.PrismLauncher
    fi

    if [[ "${OPTS[JAGEX]}" == true ]]; then
        log_info "Installing Jagex Launcher..."
        local bin_dir="$HOME/.local/bin"
        local appimage_path="$bin_dir/jagex-launcher.AppImage"
        
        # mkdir options used: -p creates parent directories without throwing errors if they exist
        mkdir -p "$bin_dir"
        
        # curl options used: -L follows HTTP redirects, -o specifies destination output file
        curl -L -o "$appimage_path" "https://rs-launcher-updates.runescape.com/production/linux/x64/latest/jagex-launcher-beta-linux-x86_64.AppImage"
        
        # chmod options used: +x adds executable permissions
        chmod +x "$appimage_path"
        
        "$appimage_path" >/dev/null 2>&1 &
        local pid=$!
        sleep 3
        # kill options used: sends SIGTERM gracefully
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    fi
}

install_utilities() {
    if [[ "${OPTS[DISCORD]}" == true ]]; then
        log_info "Installing Discord..."
        sudo dnf install -y \
          https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
          https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y discord
    fi

    if [[ "${OPTS[SUBLIME]}" == true ]]; then
        log_info "Replacing KWrite with Sublime Text..."
        sudo dnf remove -y kwrite
        # rpm options used: -v enables verbose logging, --import imports the specified GPG signing key
        sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
        sudo dnf config-manager addrepo --from-repofile=https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
        sudo dnf install -y sublime-text
    fi

    [[ "${OPTS[VLC]}" == true ]] && sudo dnf install -y vlc
    [[ "${OPTS[KDENLIVE]}" == true ]] && sudo dnf install -y kdenlive

    if [[ "${OPTS[ORCASLICER]}" == true ]]; then
        log_info "Installing OrcaSlicer via Flatpak..."
        sudo dnf install -y flatpak
        sudo flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        sudo flatpak install --system -y flathub com.orcaslicer.OrcaSlicer
    fi
}

setup_wallpaper() {
    local choice="${OPTS[WALLPAPER]}"
    if [[ "$choice" == "1" || "$choice" == "2" ]]; then
        log_info "Running Wallpaper and Panel Setup..."
        local url filename wp_dir wp_path
        
        if [[ "$choice" == "1" ]]; then
            url="https://github.com/bitflipkickflip/fedora_postinstall/blob/main/wallpapers/Fedora_GrayBlue_Penguin_2560_1440.png?raw=true"
            filename="Fedora_GrayBlue_Penguin_2560_1440.png"
        else
            url="https://github.com/bitflipkickflip/fedora_postinstall/blob/main/wallpapers/Fedora_GrayBlue_Penguin_3440_1440.png?raw=true"
            filename="Fedora_GrayBlue_Penguin_3440_1440.png"
        fi

        wp_dir="$HOME/.local/share/wallpapers"
        mkdir -p "$wp_dir"
        curl -L -o "$wp_dir/$filename" "$url"
        wp_path="$wp_dir/$filename"

        # Apply using qdbus-qt6 (standard way for KDE 6 dynamic modification)
        qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (i=0;i<allDesktops.length;i++) {
                d = allDesktops[i];
                d.wallpaperPlugin = 'org.kde.image';
                d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
                d.writeConfig('Image', 'file://$wp_path');
            }
        "
        
        # kwriteconfig6 options used: --file specifies target file, --group nests hierarchy, --key updates the value
        kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$wp_path"

        # killall options used: natively searches and sends SIGTERM to matching running process names
        kquitapp6 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null
        sleep 1
        kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 1" --key "floating" "0" 2>/dev/null
        kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 2" --key "floating" "0" 2>/dev/null
        plasmashell >/dev/null 2>&1 &
        disown
    fi
}

upgrade_system() {
    log_info "Performing Full System Upgrade..."
    # dnf options used: upgrade pulls latest definitions and updates packages, -y answers yes
    sudo dnf upgrade -y
    sudo dnf autoremove -y
}

# ==============================================================================
# MAIN ROUTINE
# ==============================================================================

menu_loop
echo -e "\n=== Starting Execution Based on Selected Options ===\n"

init_sudo_keepalive

[[ "${OPTS[KDE_BLOAT]}" == true ]] && remove_bloat
manage_browsers
[[ "${OPTS[NVIDIA]}" == true ]] && install_nvidia
install_gaming_tools
install_utilities
setup_wallpaper
[[ "${OPTS[UPGRADE]}" == true ]] && upgrade_system

echo -e "\n${C_GREEN}=== All Selected Modules Complete ===${C_RESET}"
read -r -p "Would you like to restart your system now? [Y/n]: " raw_reboot </dev/tty
reboot_choice=$(echo "$raw_reboot" | tr -d '\r' | tr '[:upper:]' '[:lower:]' | xargs)

if [[ -z "$reboot_choice" || "$reboot_choice" == "y" || "$reboot_choice" == "yes" || "$reboot_choice" == "1" ]]; then
    # pgrep options used: -x forces exact process name string match
    while pgrep -x "dnf" >/dev/null || pgrep -x "akmods" >/dev/null; do
        log_warn "Background tasks still running. Waiting 5 seconds..."
        sleep 5
    done
    
    # rm options used: -- signals end of command line options to prevent parsing accidental flags from $0
    rm -- "$0"
    sudo reboot
else
    rm -- "$0"
    log_info "Setup finished! Remember to reboot manually if you installed NVIDIA drivers."
fi
