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

1. Own and install Battlefront II (Steam: [*Star Wars Battlefront II (Classic, 2005)*](https://store.steampowered.com/app/6060/)). The game is not included here.
2. Close the game.

The **BF2 Remaster** (by Harrisonfog, about 4.8 GB, free) is also needed. It is not re-hosted here. `Install.bat` handles it for you:
it asks whether the Remaster is already installed. If you answer **N**, it opens the
[official download page](https://www.moddb.com/mods/hd-graphics-mod/downloads/battlefront-2-remaster-installer-10) on ModDB,
waits for the zip to land in your Downloads folder, unpacks it and runs Part 1, 2 and 3 in order. When each Remaster
installer asks for the game folder, pick the `GameData` folder the installer shows you.
Already installed it? Answer **Y** (or run `Install.bat -SkipRemaster`).

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

Verified on a Windows 11 PC (Steam install, 2560x1080 main monitor with two extra portrait monitors):

- The shortcut launches the game fullscreen on the main monitor.
- The profile screen and the main menu (multiplayer list) display with nothing overlapping. On widescreen monitors the menus are 4:3 with black bars on the sides by design.
- The Windows key works while the game is focused, and the mouse is not trapped.
- Install, reinstall and uninstall work, and the installer also ran correctly on a Windows 10 PC with a 4:3 screen.

Not yet tested: GOG or other non-Steam installs, 16:9 / 4K / 16:10 screens with the real game, and in-match gameplay with the Aspect Ratio Hack. If something looks wrong on your setup, open an issue and include your monitor resolution and `GameData\shader patch.log`.

## Credits and licence

Shader Patch is by PrismaticFlower and is downloaded from its official GitHub releases; see its own licence.
The BF2 Remaster is by its respective authors. This package only contains the install scripts.



