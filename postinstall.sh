#!/bin/bash

# ==========================================
# 1. Wallpaper Setup Section (Runs as User)
# ==========================================

echo "Which monitor resolution do you need?"
echo "1) 2560x1440 (Standard 1440p)"
echo "2) 3440x1440 (Ultrawide 1440p)"
read -p "Enter 1 or 2: " choice </dev/tty

if [ "$choice" == "1" ]; then
    URL="https://github.com/bitflipkickflip/fedora_postinstall/blob/main/wallpapers/Fedora_GrayBlue_Penguin_2560_1440.png?raw=true"
    FILENAME="Fedora_GrayBlue_Penguin_2560_1440.png"
elif [ "$choice" == "2" ]; then
    URL="https://github.com/bitflipkickflip/fedora_postinstall/blob/main/wallpapers/Fedora_GrayBlue_Penguin_3440_1440.png?raw=true"
    FILENAME="Fedora_GrayBlue_Penguin_3440_1440.png"
else
    echo "Invalid choice. Skipping wallpaper setup."
    exit 1
fi

WALLPAPER_DIR="$HOME/.local/share/wallpapers"

# mkdir options used:
# -p: Creates parent directories as needed, and does not fail if the directory already exists.
mkdir -p "$WALLPAPER_DIR"

# curl options used:
# -L: Follows HTTP redirects (crucial for GitHub raw or blob links).
# -o: Writes output to a specified local file instead of stdout.
curl -L -o "$WALLPAPER_DIR/$FILENAME" "$URL"
WALLPAPER_PATH="$WALLPAPER_DIR/$FILENAME"

# Apply the wallpaper to the Plasma Desktop
qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allDesktops = desktops();
    for (i=0;i<allDesktops.length;i++) {
        d = allDesktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
        d.writeConfig('Image', 'file://$WALLPAPER_PATH');
    }
"

# Apply the wallpaper to the Lockscreen as well
# kwriteconfig6 options used:
# --file: Specifies the target configuration file.
# --group: Navigates down into nested configuration groups.
# --key: Specifies the exact configuration key to update with the file path value.
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$WALLPAPER_PATH"


# ==========================================
# 2. Steam Installation Section
# ==========================================

echo ""
echo "Would you like to install Steam?"
echo "1) Yes"
echo "2) No"
read -p "Enter 1 or 2: " steam_choice </dev/tty

if [ "$steam_choice" == "1" ]; then
    echo "Enabling Fedora's third-party repositories and installing Steam..."
    
    # dnf options used:
    # install: Installs the specified package.
    # -y: Automatically answers 'yes' to any confirmation prompts during installation.
    # config-manager setopt: Updates repository configuration parameters on modern DNF5 systems.
    sudo dnf install -y fedora-workstation-repositories
    sudo dnf config-manager setopt rpmfusion-nonfree-steam.enabled=1
    sudo dnf install -y steam
    
    echo "Steam installed successfully. You can launch it from your app menu after rebooting."
else
    echo "Skipping Steam installation."
fi


# ==========================================
# 3. NVIDIA Drivers Installation Section
# ==========================================

echo ""
echo "Would you like to install the latest NVIDIA drivers?"
echo "1) Yes"
echo "2) No"
read -p "Enter 1 or 2: " nvidia_choice </dev/tty

if [ "$nvidia_choice" == "1" ]; then
    echo "Enabling RPM Fusion NVIDIA repository and installing drivers..."
    
    # dnf options used:
    # config-manager setopt: Updates repository configuration parameters on modern DNF5 systems.
    # install: Installs the specified packages (akmod-nvidia builds kernel modules, cuda adds support libraries).
    # -y: Automatically answers 'yes' to any confirmation prompts during installation.
    sudo dnf config-manager setopt rpmfusion-nonfree-nvidia-driver.enabled=1
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
    
    echo "NVIDIA drivers installed successfully. Please reboot your system after the script completes."
else
    echo "Skipping NVIDIA driver installation."
fi


# ==========================================
# 4. Discord Installation Section
# ==========================================

echo ""
echo "Would you like to install Discord?"
echo "1) Yes"
echo "2) No"
read -p "Enter 1 or 2: " discord_choice </dev/tty

if [ "$discord_choice" == "1" ]; then
    echo "Enabling RPM Fusion Nonfree Updates repository and installing Discord..."
    
    # dnf options used:
    # config-manager setopt: Enables the specific rpmfusion-nonfree-updates repository.
    # install: Installs the discord package.
    # -y: Automatically answers 'yes' to any confirmation prompts.
    sudo dnf config-manager setopt rpmfusion-nonfree-updates.enabled=1
    sudo dnf install -y discord
    
    echo "Discord installed successfully."
else
    echo "Skipping Discord installation."
fi


# ==========================================
# 5. Jagex Launcher AppImage Installation
# ==========================================

echo ""
echo "Would you like to download and install the Jagex Launcher AppImage?"
echo "1) Yes"
echo "2) No"
read -p "Enter 1 or 2: " jagex_choice </dev/tty

if [ "$jagex_choice" == "1" ]; then
    echo "Downloading Jagex Launcher..."
    
    BIN_DIR="$HOME/.local/bin"
    
    # mkdir options used:
    # -p: Creates parent directories as needed, and does not fail if the directory already exists.
    mkdir -p "$BIN_DIR"
    
    # curl options used:
    # -L: Follows HTTP redirects.
    # -o: Writes output to the destination file path.
    curl -L -o "$BIN_DIR/jagex-launcher.AppImage" "https://rs-launcher-updates.runescape.com/production/linux/x64/latest/jagex-launcher-beta-linux-x86_64.AppImage"
    
    # chmod options used:
    # +x: Adds execute permissions so the AppImage can be run directly as an executable.
    chmod +x "$BIN_DIR/jagex-launcher.AppImage"
    
    echo "Launching Jagex Launcher briefly to auto-register its menu entry and icon..."
    
    # Run the AppImage in the background (&) so the script doesn't freeze waiting for it
    "$BIN_DIR/jagex-launcher.AppImage" >/dev/null 2>&1 &
    
    # Capture the Process ID (PID) of the background command
    LAUNCHER_PID=$!
    
    # Pause for 3 seconds to give the launcher enough time to unpack its icon and metadata assets
    sleep 3
    
    # Send a graceful termination signal (SIGTERM) so it closes cleanly without crash dialogs
    kill "$LAUNCHER_PID" 2>/dev/null
    
    # Wait for the process to wind down completely
    wait "$LAUNCHER_PID" 2>/dev/null
    
    echo "Jagex Launcher registered and closed successfully."
else
    echo "Skipping Jagex Launcher installation."
fi


# ==========================================
# 6. System-Wide Upgrade Section
# ==========================================

echo ""
echo "Would you like to perform a full system-wide upgrade?"
echo "1) Yes"
echo "2) No"
read -p "Enter 1 or 2: " upgrade_choice </dev/tty

if [ "$upgrade_choice" == "1" ]; then
    echo "Performing system-wide package upgrade..."
    
    # dnf upgrade options used:
    # upgrade: Upgrades all installed system packages to their newest available versions.
    # -y: Automatically answers 'yes' to confirmation prompts.
    sudo dnf upgrade -y
    
    echo "System upgrade complete."
else
    echo "Skipping system-wide upgrade."
fi


# ==========================================
# 7. System Restart Section
# ==========================================

echo ""
echo "Would you like to restart your system now?"
echo "1) Yes"
echo "2) No"
read -p "Enter 1 or 2: " reboot_choice </dev/tty

if [ "$reboot_choice" == "1" ]; then
    echo "Checking for active package updates or driver compilations..."
    
    # Loop as long as dnf or akmods processes are still running in the background
    while pgrep -x "dnf" >/dev/null || pgrep -x "akmods" >/dev/null; do
        echo "Background tasks still running (building NVIDIA modules or updating). Waiting 5 seconds..."
        sleep 5
    done
    
    echo "All background tasks finished. Initiating system reboot..."
    
    # reboot options used:
    # sudo: Runs the reboot command with superuser privileges required to restart the OS.
    sudo reboot
else
    echo ""
    echo "Setup complete! Please remember to reboot your system manually if you installed NVIDIA drivers."
fi
