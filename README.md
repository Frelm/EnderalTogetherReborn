# Enderal Together Reborn

[![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Target: Enderal SE](https://img.shields.io/badge/Game-Enderal%20SE%20(1.7.104)-orange.svg)](https://store.steampowered.com/app/976620/Enderal_Forgotten_Stories_Special_Edition/)
[![Protocol: v1.8.4](https://img.shields.io/badge/Protocol-v1.8.4-green.svg)](https://github.com/Frelm/EnderalTogetherReborn/releases)

**Enderal Together Reborn** is a multiplayer co-op modification enabling 2–8 players to experience the world of Vyn together in *Enderal: Forgotten Stories (Special Edition)*.

---

## Credits & Acknowledgements

* **[Skyrim Together Reborn](https://github.com/tiltedphoques/TiltedEvolution) (Tilted Phoques):**
  This project is a dedicated fork of **Skyrim Together Reborn** (codename *TiltedEvolution*). Full credit goes to the **Tilted Phoques** development team for their monumental work creating the reverse-engineering framework, networking layer, client-server architecture, and UI.
* **[SureAI](https://sureai.net/):**
  The creators of *Enderal: Forgotten Stories*, for crafting one of the greatest total conversion RPGs of all time.
* **Eddoursul & the Enderal SE Team:**
  For porting and maintaining *Enderal Special Edition*.

---

## Features & Enderal Enhancements

* **True Co-Op Exploration:** Explore the continent of Vyn together, take on bounties, delve into dungeons, and fight side-by-side.
* **Synchronized Combat & Spawns:** Shared NPC spawns, health, combat AI, animations, and native shared XP progression.
* **Enderal Puzzle & Mechanism Fixes:**
  * **Temple Column Puzzle (`_00E_MQ00TemplePuzzleSCN`):** Fixed an issue where the early ruin columns only translated for the activating player. Both local and remote activations now properly animate.
  * **Dungeon Lifts & Elevators (`_00e_dungeonliftscript`):** Moving platforms and chains sync across all connected clients.
  * **Temple Exit Doors (`_00e_mqp03_exitdoorscript`):** Synchronized state progression for ruin exits.
* **Isolated Meditation (`_00e_class_openclassmenuscript`):**
  * Meditating to spend Memory Points transports only the casting player to the strange place; party members remain undisturbed in the world.
* **Engine & Profile Isolation:**
  * Uses dedicated Enderal Special Edition registry keys and profiles, completely isolated from vanilla Skyrim SE installations.
  * Bundled crash prevention overrides and null-pointer checks for Enderal's unique game environment.
* **Target Runtime:**
  * Built natively for **Enderal Special Edition runtime 1.7.104.0** (standard Steam version).

---

## Getting Started

### 1. Requirements
* A clean installation of **[Enderal: Forgotten Stories (Special Edition)](https://store.steampowered.com/app/976620/Enderal_Forgotten_Stories_Special_Edition/)** on Steam.
* Recommended: **[Mod Organizer 2](https://github.com/ModOrganizer2/modorganizer)** or manual installation.

### 2. Client Setup
1. Download `EnderalTogetherReborn-Client-v1.8.4.zip` from the [Releases](https://github.com/Frelm/EnderalTogetherReborn/releases) tab.
2. Install the archive through Mod Organizer 2 as a mod, or extract its contents directly into your game's root directory.
3. Launch the game using `SkyrimTogether.exe` (located in `SkyrimTogetherRuntime/`).
4. Press **F2** (or your configured hotkey) in-game to open the party and connection overlay.

### 3. Server Setup
1. Download `EnderalTogether-Server-v1.8.4.zip` from [Releases](https://github.com/Frelm/EnderalTogetherReborn/releases).
2. Extract the server files to any folder or host machine.
3. Edit `config/STServer.ini` to adjust your server port, player limit, or password.
4. Launch `SkyrimTogetherServer.exe`.
5. If hosting over the internet, forward port **10578 UDP** (default).

---

## Building from Source

This project uses the **[xmake](https://xmake.io/)** build utility and requires **Visual Studio 2022 (MSVC v143, C++20)**.

### Prerequisites
1. **Visual Studio 2022 Community** (Workload: *Desktop development with C++*, MSVC v143, Windows 10/11 SDK).
2. **Git** with submodule support.
3. **xmake** (`winget install xmake` or download from [xmake.io](https://xmake.io/)).

### Step-by-Step Build Instructions

1. **Clone the repository recursively (required for submodules in `/Libraries`):**
   ```bash
   git clone --recursive https://github.com/Frelm/EnderalTogetherReborn.git
   cd EnderalTogetherReborn
   ```
   *(If already cloned without `--recursive`, run: `git submodule update --init --recursive`)*

2. **Configure the build:**
   ```bash
   xmake f -m release -y
   ```
   *xmake will automatically resolve and download package dependencies (such as CEF and Discord).*

3. **Compile the mod targets:**
   ```bash
   # Build the client launcher (SkyrimTogether.exe)
   xmake build SkyrimImmersiveLauncher

   # Build the dedicated server (SkyrimTogetherServer.exe + STServer.dll)
   xmake build SkyrimTogetherServer
   ```

4. **(Optional) Generate a Visual Studio 2022 Solution:**
   ```bash
   xmake project -k vsxmake
   ```
   Open `vsxmake2022/EnderalTogether-src.sln` directly in Visual Studio 2022.

### Output Binaries
Compiled files will be located in:
`build/windows/x64/release/`
* `SkyrimTogether.exe` (Launcher + Client)
* `SkyrimTogetherServer.exe` (Dedicated Server Host)
* `STServer.dll` (Server Logic)
* `EarlyLoad.dll` (MO2 / Early Loader)
* `TPProcess.exe` (UI Overlay Worker)

---

## Project Structure

* [**Code/client/**](./Code/client): Client logic, engine hooks, Enderal quest/event guards, and synchronization handlers.
* [**Code/immersive_launcher/**](./Code/immersive_launcher): `SkyrimTogether.exe` launcher, process injection, and address library loader.
* [**Code/server/**](./Code/server): Dedicated server core (`STServer.dll`).
* [**Code/server_runner/**](./Code/server_runner): `SkyrimTogetherServer.exe` runner for hosting dedicated servers.
* [**Code/encoding/**](./Code/encoding): Shared network protocol packets and serializer structs.
* [**Code/skyrim_ui/**](./Code/skyrim_ui): CEF-based Angular in-game UI overlay.
* [**GameFiles/**](./GameFiles): Papyrus scripts, quest patches, and assets shipped with the mod.
* [**Libraries/**](./Libraries): Git submodules (TiltedConnect, TiltedHooks, TiltedReverse, TiltedUI).

---

## License

This project is licensed under the **GNU General Public License v3.0 (GPLv3)** in accordance with the upstream TiltedEvolution codebase. See [LICENSE](./LICENSE) for details.
