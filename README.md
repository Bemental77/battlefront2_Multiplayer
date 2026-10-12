# Battlefront II (2005) HD - Windows key, mouse and ultrawide fix

## [Download (ZIP)](https://github.com/Bemental77/battlefront2_Multiplayer/archive/refs/heads/main.zip)

1. Click **Download (ZIP)** above and unzip it anywhere.
2. Double-click **Install.bat**.
3. Launch the game from the new **Star Wars Battlefront II HD** desktop shortcut.

If Windows SmartScreen warns about the `.bat` file, choose *More info* > *Run anyway*. The scripts are plain text and open in Notepad.
Fixes three problems with Star Wars Battlefront II (Classic, 2005) after installing the BF2 Remaster:

- The **Windows key does nothing** while the game is focused, and you can't take screenshots.
- The **mouse gets locked** inside the game window.
- On **widescreen / ultrawide** monitors the menus are stretched, cut off or overlapping.

It does this by installing [Shader Patch](https://github.com/PrismaticFlower/shaderpatch) (by PrismaticFlower)
into the game, configuring it for your monitor, and giving you a shortcut that launches the game correctly.
Shader Patch replaces the game's old exclusive-fullscreen DirectX 9 output with a modern one, which is what
lets the Windows key, overlays (Discord, NVIDIA, Steam) and screenshots work.

## Before you start

1. Install Battlefront II (Steam: *Star Wars Battlefront II (Classic, 2005)*).
2. Run the Remaster installers **in order** (Part 1, then 2, then 3). This package does not replace them.
3. Close the game.

## Install

1. Unzip this folder anywhere.
2. Double-click **Install.bat**.
3. It finds your Steam install automatically. If it can't (GOG, other launcher), paste the path to the
   `GameData` folder, the one that contains `BattlefrontII.exe`.
4. Launch the game from the new **Star Wars Battlefront II HD** desktop shortcut.

The installer:
- downloads the latest Shader Patch release from GitHub (nothing is bundled),
- backs up any `d3d9.dll`, `d3dcompiler_47.dll` and `shader patch.yml` you already had (first install only),
- turns on Shader Patch's **Aspect Ratio Hack** only if your main monitor is wider than 16:9,
- creates the desktop shortcut.

It is safe to run again; your Shader Patch settings are kept.

## Important: do not force a resolution

Do **not** add `/resolution ...` to the launch options or the shortcut on a widescreen or ultrawide monitor.
The Remaster's own shortcut does this. A forced resolution overrides Shader Patch's menu handling and
stretches or overlaps the menus. Use the shortcut this installer makes (Steam: `-applaunch 6060`).

## Settings

Run `GameData\Shader Patch Settings.exe`, or edit `GameData\shader patch.yml`. Useful options:

| Setting | What it does |
| --- | --- |
| `Aspect Ratio Hack` | Makes gameplay fill an ultrawide screen. Loading screens can look distorted with it on. Set `no` if the picture looks wrong. |
| `Aspect Ratio Hack HUD Handling` | `Centre 4_3` (default), `Stretch 4_3`, `Centre 16_9`, `Stretch 16_9`. |
| `Stretch Interface` | `no` keeps the menus 4:3 with black bars (default). `yes` stretches them across the screen. |
| `Extra UI Scaling` | Percent. Raise for bigger text on high-DPI screens. |

## Uninstall

Double-click **Uninstall.bat** (paste the `GameData` path when asked). It removes Shader Patch and restores the
files it backed up.

## Troubleshooting

- **"Close Battlefront II first"**: the game is running from that folder. Quit it and run again.
- **Game starts minimized**: click it in the taskbar. If this happens every time, please report it.
- **Menus still look wrong**: check the shortcut has no `/resolution` and Steam's launch options for the game are empty.
- **Game won't start at all**: run the uninstaller to rule out the patch, then report the problem along with
  `GameData\BFront2.log`.
- Shader Patch needs Windows 10 or newer and a GPU supporting Direct3D 11.

## Status

Tested on one machine (Windows 11, Steam install, a 2560x1080 main monitor with two extra portrait monitors).
Installer, reinstall and uninstall were tested against a fake game folder and the detection against a real
Steam install. Other setups (GOG, 4K, 16:9) are untested.

## Credits and licence

Shader Patch is by PrismaticFlower and is downloaded from its official GitHub releases; see its own licence.
The BF2 Remaster is by its respective authors. This package only contains the install scripts.

