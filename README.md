# Fedora_Post-Install-Script

```bash
curl -sO https://raw.githubusercontent.com/bitflipkickflip/fedora_postinstall/main/postinstall.sh && bash postinstall.sh
```
* **Automated Package & Repo Setup:** Configures RPM Fusion repos and installs popular applications and drivers:
  * Discord, Steam, Brave Browser, Jagex Launcher, Prism Launcher, VLC, and Sublime Text (replaces KWrite).
  * NVIDIA drivers (optional).
* **Bloatware Removal:** Automatically cleans up pre-installed KDE PIM apps, extra media utilities, games, and Firefox.
* **Desktop Customization:** Automatically sets up custom Fedora wallpapers and panel layouts (supports Standard 1440p and Ultrawide 1440p).
* **System Maintenance:** Handles full system-wide upgrades and automated cleanup as the final step.

## Execution Order
1. Remove Bloatware & Firefox
2. Install NVIDIA Drivers (if enabled)
3. Install Software & Repositories
4. Wallpaper & Panel Setup
5. Full System Upgrade & Cleanup

## Important Notes

* **RuneLite:** If you have an existing `.runelite` folder from a previous installation, make sure to place it in `/home/$USER/.runelite` before launching.
* **Steam:** The first time you launch Steam, it will take a minute or two to configure Valve runtime components. Just be patient.
* **NVIDIA Drivers:** Set to `false` by default to avoid compilation locks during initial script execution, but can be toggled on in the interactive menu.

---
*Vibe coded with ~~love~~ gemini (free tier slop)*
