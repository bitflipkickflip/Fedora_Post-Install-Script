#!/bin/bash

# 1. Prompt the user for their resolution
echo "Which monitor resolution do you need?"
echo "1) 2560x1440 (Standard 1440p)"
echo "2) 3440x1440 (Ultrawide 1440p)"
read -p "Enter 1 or 2: " choice

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
mkdir -p "$WALLPAPER_DIR"
curl -L -o "$WALLPAPER_DIR/$FILENAME" "$URL"
WALLPAPER_PATH="$WALLPAPER_DIR/$FILENAME"

# 4. Apply the wallpaper to the Plasma Desktop
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allDesktops = desktops();
    for (i=0;i<allDesktops.length;i++) {
        d = allDesktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
        d.writeConfig('Image', 'file://$WALLPAPER_PATH');
    }
"

# 5. Apply the wallpaper to the Lockscreen
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$WALLPAPER_PATH"
