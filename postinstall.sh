#!/bin/bash

# 1. Prompt the user for their resolution
echo "Which monitor resolution do you need?"
echo "1) 2560x1440 (Standard 1440p)"
echo "2) 3440x1440 (Ultrawide 1440p)"
read -p "Enter 1 or 2: " choice </dev/tty

# 2. Set the URL and filename based on the choice
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

# 3. Create the KDE wallpapers directory and download the image
WALLPAPER_DIR="$HOME/.local/share/wallpapers"

# mkdir options used:
# -p: Creates parent directories as needed, and does not fail if the directory already exists.
mkdir -p "$WALLPAPER_DIR"

# curl options used:
# -L: Follows HTTP redirects (crucial for GitHub raw or blob links).
# -o: Writes output to a specified local file instead of stdout.
curl -L -o "$WALLPAPER_DIR/$FILENAME" "$URL"
WALLPAPER_PATH="$WALLPAPER_DIR/$FILENAME"

# 4. Apply the wallpaper to the Plasma Desktop (Using qdbus-qt6 for Plasma 6)
qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allDesktops = desktops();
    for (i=0;i<allDesktops.length;i++) {
        d = allDesktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
        d.writeConfig('Image', 'file://$WALLPAPER_PATH');
    }
"

# 5. Apply the wallpaper to the Lockscreen
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
    echo "Enabling RPM Fusion Steam repository and installing Steam..."
    
    # dnf5-compatible options used:
    # config-manager setopt: Updates repository configuration parameters on modern DNF5 systems.
    # -y: Automatically answers 'yes' to any confirmation prompts during installation.
    sudo dnf config-manager setopt rpmfusion-nonfree-steam.enabled=1
    sudo dnf install -y steam
else
    echo "Skipping Steam installation."
fi
