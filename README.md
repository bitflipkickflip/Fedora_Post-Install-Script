# Fedora_Post-Install-Script

```bash
curl -sO https://raw.githubusercontent.com/bitflipkickflip/fedora_postinstall/main/postinstall.sh && bash postinstall.sh
```
* Automates install of RPM Fusion repos and packages
  * Discord, Steam, Brave, Jagex Launcher, NVIDIA drivers
  * Offers to remove Firefox & KDE bloat apps 
    * **If you have a .runelite folder from another runelite install put it in /home/$USER/.runelite**
* Vibe coded with ~~love~~ gemini (free tier slop)
* First time launching steam will take a minute due to some valve runtime stuff. Just be patient.
