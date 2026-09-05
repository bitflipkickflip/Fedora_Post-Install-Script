#!/bin/bash

# ==============================================================================
# GLOBAL CONFIGURATION DEFAULTS (All off by default, Wallpaper set to 1)
# ==============================================================================
WALLPAPER_CHOICE="1"          # 1: 2560x1440 (Default), 2: 3440x1440, 3: Skip
OPT_STEAM="false"
OPT_BRAVE="false"
OPT_FIREFOX_REMOVE="false"
OPT_NVIDIA="false"
OPT_DISCORD="false"
OPT_PRISM="false"
OPT_JAGEX="false"
OPT_KDE_BLOAT="false"
OPT_SUBLIME="false"
OPT_VLC="false"
OPT_UPGRADE="false"

# ==============================================================================
# INTERACTIVE CONFIGURATION MENU
# ==============================================================================
show_options() {
    clear
    echo "========================================================"
    echo "         FEDORA POST-INSTALLATION CONFIGURATOR          "
    echo "========================================================"
    echo " Module / Option                  Current Status        "
    echo "--------------------------------------------------------"
    
    # printf options used: %-32s pads the string to exactly 32 characters left-aligned to lock colons in place
    printf " %-32s : %s\n" "[1] Wallpaper Setup" "$(if [ "$WALLPAPER_CHOICE" == "3" ]; then echo "Disabled (3)"; else echo "Resolution $WALLPAPER_CHOICE"; fi)"
    printf " %-32s : %s\n" "[2] Install Steam" "$OPT_STEAM"
    printf " %-32s : %s\n" "[3] Install Brave" "$OPT_BRAVE"
    printf " %-32s : %s\n" "[4] Remove Firefox" "$OPT_FIREFOX_REMOVE"
    printf " %-32s : %s\n" "[5] Install NVIDIA" "$OPT_NVIDIA"
    printf " %-32s : %s\n" "[6] Install Discord" "$OPT_DISCORD"
    printf " %-32s : %s\n" "[7] Install Prism Launcher" "$OPT_PRISM"
    printf " %-32s : %s\n" "[8] Install Jagex Launcher" "$OPT_JAGEX"
    printf " %-32s : %s\n" "[9] Remove KDE Bloat" "$OPT_KDE_BLOAT"
    printf " %-32s : %s\n" "[10] Replace KWrite w/ Sublime" "$OPT_SUBLIME"
    printf " %-32s : %s\n" "[11] Install VLC" "$OPT_VLC"
    printf " %-32s : %s\n" "[12] System Upgrade" "$OPT_UPGRADE"

    echo "========================================================"
    echo " Wallpaper Options (select via #1):"
    echo "   1 = Standard 1440p (2560x1440) [Default]"
    echo "   2 = Ultrawide 1440p (3440x1440)"
    echo "   3 = Skip Wallpaper Setup"
    echo "--------------------------------------------------------"
    echo " Enter module number to toggle/configure (1-12)"
    echo " Type 'run' or 'r' to execute script"
    echo " Type 'quit' or 'q' to abort"
    echo "========================================================"
}

toggle_option() {
    local choice=$1
    case "$choice" in
        1)
            echo ""
            echo "Select wallpaper setup option:"
            echo "1) 2560x1440 (16:9 - Standard 1440p)"
            echo "2) 3440x1440 (21:9 - Ultrawide 1440p)"
            echo "3) Skip wallpaper setup"
            read -p "Enter choice (1-3): " WALLPAPER_CHOICE </dev/tty
            ;;
        2)
            if [ "$OPT_STEAM" == "true" ]; then OPT_STEAM="false"; else OPT_STEAM="true"; fi
            ;;
        3)
            if [ "$OPT_BRAVE" == "true" ]; then OPT_BRAVE="false"; else OPT_BRAVE="true"; fi
            ;;
        4)
            if [ "$OPT_FIREFOX_REMOVE" == "true" ]; then OPT_FIREFOX_REMOVE="false"; else OPT_FIREFOX_REMOVE="true"; fi
            ;;
        5)
            if [ "$OPT_NVIDIA" == "true" ]; then OPT_NVIDIA="false"; else OPT_NVIDIA="true"; fi
            ;;
        6)
            if [ "$OPT_DISCORD" == "true" ]; then OPT_DISCORD="false"; else OPT_DISCORD="true"; fi
            ;;
        7)
            if [ "$OPT_PRISM" == "true" ]; then OPT_PRISM="false"; else OPT_PRISM="true"; fi
            ;;
        8)
            if [ "$OPT_JAGEX" == "true" ]; then OPT_JAGEX="false"; else OPT_JAGEX="true"; fi
            ;;
        9)
            if [ "$OPT_KDE_BLOAT" == "true" ]; then OPT_KDE_BLOAT="false"; else OPT_KDE_BLOAT="true"; fi
            ;;
        10)
            if [ "$OPT_SUBLIME" == "true" ]; then OPT_SUBLIME="false"; else OPT_SUBLIME="true"; fi
            ;;
        11)
            if [ "$OPT_VLC" == "true" ]; then OPT_VLC="false"; else OPT_VLC="true"; fi
            ;;
        12)
            if [ "$OPT_UPGRADE" == "true" ]; then OPT_UPGRADE="false"; else OPT_UPGRADE="true"; fi
            ;;
        *)
            echo "Invalid option. Press Enter to continue..."
            read </dev/tty
            ;;
    esac
}

# Interactive Loop
while true; do
    show_options
    read -p "set > " input </dev/tty
    
    # tr options used: '[:upper:]' '[:lower:]' translates all uppercase input to lowercase
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    
    if [ "$input" == "run" ] || [ "$input" == "r" ]; then
        break
    elif [ "$input" == "quit" ] || [ "$input" == "q" ]; then
        echo "Abort requested. Exiting."
        exit 0
    else
        toggle_option "$input"
    fi
done

echo ""
echo "=== Starting Execution Based on Selected Options ==="
echo ""

# ==============================================================================
# SUDO AUTHENTICATION & KEEP-ALIVE INITIALIZATION
# ==============================================================================
# sudo options used: -v validates and updates the user's sudo timestamp upfront
sudo -v

# Background loop options used: runs non-interactively every 60 seconds to keep sudo alive, 
# and automatically terminates when the parent script exits via kill -0 check on PID ($$)
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
done 2>/dev/null &


# ==============================================================================
# 1. KDE Bloatware Removal Section
# ==============================================================================
if [ "$OPT_KDE_BLOAT" == "true" ]; then
    echo "[+] Executing KDE Bloatware Removal..."
    
    local PIM_PACKAGES=(
        "kontact" "kmail" "korganizer" "akregator" "kaddressbook"
        "kcontacts" "kaccounts-integration" "kaccounts-providers"
        "akonadi-server" "akonadi-contacts" "akonadi-calendar"
        "kdepim-addons" "akonadiconsole" "itinerary"
    )
    local MEDIA_MISC_PACKAGES=(
        "elisa-player" "dragon" "kamoso" "kate" "khelpcenter" "kfind" "konqueror"
    )
    local GAMES_AND_UTILITIES=(
        "kpatience" "kmines" "ksudoku" "kinfocenter"
    )

    TARGETS=(
        "${PIM_PACKAGES[@]}" 
        "${MEDIA_MISC_PACKAGES[@]}" 
        "${GAMES_AND_UTILITIES[@]}"
    )

    # dnf options used: remove uninstalls packages, -y answers yes automatically
    sudo dnf remove -y "${TARGETS[@]}"
    
    # dnf options used: autoremove strips unneeded orphaned libraries
    sudo dnf autoremove -y

    # find options used: -iname matches case-insensitively, -exec rm -rf {} + passes all found paths to rm recursively
    local CONFIG_PATTERNS=(
        "*kontact*" "*kmail*" "*akonadi*" "*korganizer*" "*elisa*" 
        "*kaccounts*" "*kpatience*" "*kmines*" "*ksudoku*"
    )
    for pattern in "${CONFIG_PATTERNS[@]}"; do
        find ~/.config ~/.local/share ~/.cache -iname "$pattern" -exec rm -rf {} + 2>/dev/null
    done
fi


# ==============================================================================
# 2. Firefox Removal Section
# ==============================================================================
if [ "$OPT_FIREFOX_REMOVE" == "true" ]; then
    echo "[+] Removing Firefox..."
    sudo dnf remove -y firefox
fi


# ==============================================================================
# 3. Steam Installation Section
# ==============================================================================
if [ "$OPT_STEAM" == "true" ]; then
    echo "[+] Installing Steam..."
    sudo dnf install -y fedora-workstation-repositories
    sudo dnf config-manager setopt rpmfusion-nonfree-steam.enabled=1
    sudo dnf install -y steam
fi


# ==============================================================================
# 4. Brave Browser Installation Section
# ==============================================================================
if [ "$OPT_BRAVE" == "true" ]; then
    echo "[+] Installing Brave Browser..."
    # dnf options used: config-manager addrepo --from-repofile pulls repository configuration from a direct URL
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo dnf install -y brave-browser
fi


# ==============================================================================
# 5. Discord Installation Section
# ==============================================================================
if [ "$OPT_DISCORD" == "true" ]; then
    echo "[+] Installing Discord..."
    # dnf options used: installs direct .rpm URLs to setup RPM Fusion repositories
    sudo dnf install -y \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y discord
fi


# ==============================================================================
# 6. Prism Launcher Installation Section
# ==============================================================================
if [ "$OPT_PRISM" == "true" ]; then
    echo "[+] Installing Prism Launcher via Flatpak..."
    sudo dnf install -y flatpak
    # sudo options used: runs command as root to prevent PolicyKit GUI password prompts
    # flatpak options used: remote-add registers source repo, --if-not-exists avoids duplicates, --system installs globally, install pulls flatpak app, -y answers yes
    sudo flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install --system -y flathub org.prismlauncher.PrismLauncher
fi


# ==============================================================================
# 7. Jagex Launcher AppImage Installation
# ==============================================================================
if [ "$OPT_JAGEX" == "true" ]; then
    echo "[+] Installing Jagex Launcher..."
    BIN_DIR="$HOME/.local/bin"
    # mkdir options used: -p creates parent directories as needed without throwing errors if they exist
    mkdir -p "$BIN_DIR"
    
    # curl options used: -L follows redirects, -o specifies the output file destination
    curl -L -o "$BIN_DIR/jagex-launcher.AppImage" "https://rs-launcher-updates.runescape.com/production/linux/x64/latest/jagex-launcher-beta-linux-x86_64.AppImage"
    
    # chmod options used: +x adds executable permissions to the file
    chmod +x "$BIN_DIR/jagex-launcher.AppImage"
    
    "$BIN_DIR/jagex-launcher.AppImage" >/dev/null 2>&1 &
    LAUNCHER_PID=$!
    sleep 3
    # kill options used: sends SIGTERM to gracefully close the application PID
    kill "$LAUNCHER_PID" 2>/dev/null
    wait "$LAUNCHER_PID" 2>/dev/null
fi


# ==============================================================================
# 8. Wallpaper & Panel Setup Section
# ==============================================================================
if [ "$WALLPAPER_CHOICE" == "1" ] || [ "$WALLPAPER_CHOICE" == "2" ]; then
    echo "[+] Running Wallpaper and Panel Setup..."
    
    if [ "$WALLPAPER_CHOICE" == "1" ]; then
        URL="https://github.com/bitflipkickflip/fedora_postinstall/blob/main/wallpapers/Fedora_GrayBlue_Penguin_2560_1440.png?raw=true"
        FILENAME="Fedora_GrayBlue_Penguin_2560_1440.png"
    elif [ "$WALLPAPER_CHOICE" == "2" ]; then
        URL="https://github.com/bitflipkickflip/fedora_postinstall/blob/main/wallpapers/Fedora_GrayBlue_Penguin_3440_1440.png?raw=true"
        FILENAME="Fedora_GrayBlue_Penguin_3440_1440.png"
    fi

    WALLPAPER_DIR="$HOME/.local/share/wallpapers"
    mkdir -p "$WALLPAPER_DIR"
    
    curl -L -o "$WALLPAPER_DIR/$FILENAME" "$URL"
    WALLPAPER_PATH="$WALLPAPER_DIR/$FILENAME"

    qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var allDesktops = desktops();
        for (i=0;i<allDesktops.length;i++) {
            d = allDesktops[i];
            d.wallpaperPlugin = 'org.kde.image';
            d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
            d.writeConfig('Image', 'file://$WALLPAPER_PATH');
        }
    "
    # kwriteconfig6 options used: --file specifies target config, --group nests configuration layers, --key defines target property
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$WALLPAPER_PATH"

    # killall options used: cleanly terminates all instances of plasmashell
    kquitapp6 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null
    sleep 1
    kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 1" --key "floating" "0" 2>/dev/null
    kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 2" --key "floating" "0" 2>/dev/null
    plasmashell >/dev/null 2>&1 &
fi


# ==============================================================================
# 9. Replace KWrite with Sublime Text Section
# ==============================================================================
if [ "$OPT_SUBLIME" == "true" ]; then
    echo "[+] Replacing KWrite with Sublime Text..."
    # dnf options used: remove uninstalls package, -y answers yes
    sudo dnf remove -y kwrite
    # rpm options used: -v enables verbose output, --import imports the specified GPG signing key
    sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
    # dnf options used: config-manager addrepo --from-repofile pulls repository configuration from a direct URL (DNF5 syntax)
    sudo dnf config-manager addrepo --from-repofile=https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
    sudo dnf install -y sublime-text
fi


# ==============================================================================
# 10. VLC Media Player Installation Section
# ==============================================================================
if [ "$OPT_VLC" == "true" ]; then
    echo "[+] Installing VLC Media Player..."
    # dnf options used: install adds package, -y answers yes automatically
    sudo dnf install -y vlc
fi


# ==============================================================================
# 11. NVIDIA Drivers Installation Section (2nd Last)
# ==============================================================================
if [ "$OPT_NVIDIA" == "true" ]; then
    echo "[+] Installing NVIDIA Drivers..."
    # dnf options used: config-manager setopt enables a specific repository
    sudo dnf config-manager setopt rpmfusion-nonfree-nvidia-driver.enabled=1
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
fi


# ==============================================================================
# 12. System-Wide Upgrade Section (Last Execution Module)
# ==============================================================================
if [ "$OPT_UPGRADE" == "true" ]; then
    echo "[+] Performing Full System Upgrade..."
    # dnf options used: upgrade updates all installed packages, -y answers yes
    sudo dnf upgrade -y
    sudo dnf autoremove -y
fi


# ==============================================================================
# 13. System Restart Section
# ==============================================================================
echo ""
echo "=== All Selected Modules Complete ==="
read -p "Would you like to restart your system now? (1) Yes (2) No: " reboot_choice </dev/tty

if [ "$reboot_choice" == "1" ]; then
    # pgrep options used: -x mandates an exact match of the process name
    while pgrep -x "dnf" >/dev/null || pgrep -x "akmods" >/dev/null; do
        echo "Background tasks still running. Waiting 5 seconds..."
        sleep 5
    done
    
    # 0. Clean up script (Runs right before reboot)
    rm -- "$0"
    
    # reboot options used: gracefully reboots the system
    sudo reboot
else
    # 0. Clean up script (Runs right before exiting)
    rm -- "$0"
    echo "Setup finished! Remember to reboot manually if you installed NVIDIA drivers."
fi
