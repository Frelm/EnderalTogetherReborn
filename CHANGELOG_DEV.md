# Enderal Together Reborn — Developer Change Log & Architecture Tracker

> **Notice:** This document is the primary source of truth across development sessions. Always consult and update this file when making changes or investigating bugs.

---

## 1. Project Overview & Environment

* **Target Game:** *Enderal: Forgotten Stories (Special Edition)* v2.1.4 (Steam)
* **Underlying Engine:** Bethesda Skyrim Special Edition runtime `1.7.104.0` (AE binary layout)
* **Base Multiplayer Codebase:** *Tilted Evolution* / *Skyrim Together Reborn* (branch `feature/legacy-1.5.97-on-1.8.7` adapted for Enderal 1.7.104)
* **Local Source Tree:** `C:\Users\Artyom\Documents\antigravity\proud-hopper\skyrim\EnderalTogether-src`
* **Local Branch:** `feature/enderal-together`
* **Remote Repository:** [https://github.com/Frelm/EnderalTogetherReborn](https://github.com/Frelm/EnderalTogetherReborn) (`main`)
* **Distribution Staging:** `C:\Users\Artyom\Documents\antigravity\proud-hopper\EnderalTogether-Release\`
* **Installed Test Locations:**
  * MO2 Instance 1: `C:\Users\Artyom\AppData\Local\ModOrganizer\Enderal Special Edition\mods\EnderalTogetherReborn\`
  * MO2 Instance 2: `C:\Users\Artyom\AppData\Local\ModOrganizer\Enderal Special Edition (2)\mods\EnderalTogetherReborn\`
  * Base Game / Vortex: `H:\SteamLibrary\steamapps\common\Enderal Special Edition\Data\SkyrimTogetherRuntime\`

---

## 2. Completed Milestones & Historical Fixes

### 2.1 Launcher Target & Engine Binary Compatibility
* **Issue:** Initially built the `SkyrimImmersiveLauncherLegacy` target targeting 1.5.97, triggering version mismatch popups.
* **Fix:** Configured and compiled the modern `SkyrimImmersiveLauncher` targeting `1.7.104.0`.

### 2.2 Registry Key & Multi-Install Isolation
* **Issue:** Default launcher read `HKCU\Software\TiltedPhoques\TiltedEvolution\Skyrim Special Edition`, overriding the user's regular Skyrim SE install and launching vanilla Skyrim instead of Enderal.
* **Fix:** Isolated registry path in `Code/immersive_launcher/TargetConfig.h` to `L"Enderal Special Edition"`, completely isolating registry keys and game paths.

### 2.3 Null Pointer Guards for Enderal Engine Quirks
* **Issue:** Crash loops within 5 minutes of gameplay due to missing vanilla Skyrim global variables.
* **Fix:**
  * Guarded `WorldEventsEnabled` (`0xB8EC1`) in `PlayerService.cpp`.
  * Guarded `KillMove` (`0x100F19`) in `PartyService.cpp`.

### 2.4 Quest Synchronization & Exploration Mode
* **Issue:** Quest sync desynced Enderal's heavily scripted story, Meditation worldspace, and custom Papyrus alias mechanics.
* **Fix:**
  * Set `bDisableQuestSync = true` in `EnderalTogether.ini`.
  * Added Enderal core quest blacklist (`_00E_PlayerQuest`, `_00E_LevelUpQuest`, `_00E_MeditationQuest`, `_00E_AffinityQuest`, `_00E_FatigueQuest`, `_00E_ArkanistenfieberQuest`, etc.) in `QuestService.cpp`.
  * Configured Exploration & Combat Co-op Mode as default.

### 2.5 EngineFixes Memory Manager Compatibility
* **Issue:** Instant CTD (`EngineFixes.dll+0x96e34`) upon actor/player spawning due to memory pool conflicts with STR's custom `ExActor` extensions.
* **Fix:** Provided pre-configured `SKSE/Plugins/EngineFixes.toml` disabling `[MemoryManager]` overrides (`bOverrideMemoryManager = false`).

### 2.6 Network Protocol Synchronization & Opcode Alignment
* **Issue:** Server handshake rejected with `v1.8.4` vs `legacy-test` error; remote players invisible and empty Player Manager list due to packet opcode misalignment between server and client.
* **Fix:**
  * Pinned `BUILD_COMMIT` to `"v1.8.4"` in `BuildInfo.h.in`.
  * Added dynamic INI protocol configuration (`sProtocolVersion = v1.8.4`) and auto-adoption in `TransportService.cpp`.
  * Recompiled both `SkyrimTogether.exe`, `SkyrimTogetherServer.exe`, and `STServer.dll` from the exact same source tree.

### 2.7 Packaging & Distribution
* **Archives Built:**
  * `EnderalTogetherReborn.zip` (All-in-One: Client mod structure + `Server\` folder + pre-configured `EngineFixes.toml`).
  * `EnderalTogetherReborn-Client-v1.8.4.zip` (Client only).
  * `EnderalTogether-Server-v1.8.4.zip` (Dedicated server only).
* **Source Published:** Pushed to GitHub repository [Frelm/EnderalTogetherReborn](https://github.com/Frelm/EnderalTogetherReborn).

---

## 3. Dungeon & Puzzle Synchronization (Resolved)

### 3.1 Temple Columns / Skeleton Key Puzzle (`_00E_MQ00TemplePuzzleSCN`)
* **Symptom:** In the early temple ruins, when one player inserted the Temple Key into the pedestal to raise the stone columns/pillars, the columns only moved for the activating player. The remote player saw nothing happen.
* **Root Cause:**
  * In `_00E_MQ00TemplePuzzleSCN.psc`, activation strictly required:
    ```papyrus
    Actor PlayerRef = Game.GetForm(0x14) as Actor
    if akActionRef == PlayerRef && !Activated && (PlayerRef.GetItemCount(_00E_MQ00TempleKey) >= 1)
    ```
  * When Player 1 activated the keyhole, STR sent `NotifyActivate` to Player 2. On Player 2's client, `akActionRef` was Player 1's remote actor, while `PlayerRef` evaluated to Player 2 (local player). Thus `akActionRef == PlayerRef` evaluated to `false`, and the script aborted.
* **Fix:**
  * Updated `_00E_MQ00TemplePuzzleSCN.psc` to verify if the activator is either the local player (with key) or a remote player using `SkyrimTogetherUtils.IsRemotePlayer(actActor)`:
    ```papyrus
    bool isLocal = (akActionRef == PlayerRef)
    bool isRemote = (actActor != None && (SkyrimTogetherUtils.IsRemotePlayer(actActor) || (actActor != PlayerRef && SkyrimTogetherUtils.IsPlayer(actActor))))
    if !Activated && ((isLocal && PlayerRef.GetItemCount(_00E_MQ00TempleKey) >= 1) || isRemote)
    ```
  * If local, consumes 1 key. If remote, skips inventory removal (the remote player already spent the key) and immediately begins the synchronized column rise animation and sound effects.

### 3.2 Meditation Co-op Isolation (`_00e_class_openclassmenuscript`)
* **Symptom:** When Player 1 pressed the hotkey to meditate (to spend Memory Points), Player 2 was unexpectedly transported to the meditation temple as well.
* **Root Cause:**
  * Meditating triggers `_00E_Class_Meditate` / `_00E_Class_OpenClassMenuSpell`.
  * `MagicService` replicates spell target additions across the network.
  * In `_00e_class_openclassmenuscript.psc`, `Event OnEffectStart(Actor TheTarget, Actor TheCaster)` did not check whether the current caster was the local player before calling `PlayerREF.MoveTo(_00E_ClassMenuOrigin)`.
* **Fix:**
  * Added guard at the very beginning of `OnEffectStart`:
    ```papyrus
    If TheCaster != Game.GetPlayer()
        Return
    EndIf
    ```
  * When Player 1 meditates, Player 2's client receives the magic effect notification, sees `TheCaster != Game.GetPlayer()`, and returns immediately without interrupting Player 2 or moving them.

### 3.3 Dungeon Lifts & Elevators (`_00e_dungeonliftscript`)
* **Symptom:** Dungeon lifts/elevators triggered by remote players or linked levers did not move for both players.
* **Fix:**
  * Updated `_00e_dungeonliftscript.psc` so that `OnActivate` accepts activations from local player, remote players via `SkyrimTogetherUtils.IsPlayer(actActor)`, and non-actor switch triggers (`!(akActionRef as Actor)`).
  * Local player controls are only disabled if the local player is the direct activator.

### 3.4 Temple Exit Door (`_00e_mqp03_exitdoorscript`)
* **Fix:** Updated `_00e_mqp03_exitdoorscript.psc` so activating the exit door by either player properly updates the quest stage.

### 3.5 Deployment
* Recompiled all 4 scripts into `.pex` using native `PapyrusCompiler.exe`.
* Synchronized `.pex` and `.psc` files to:
  * Local source repo: `GameFiles/Skyrim/scripts/`
  * Both MO2 test instances: `mods/EnderalTogetherReborn/scripts/`
  * Base game / Vortex directory: `Data/scripts/`
  * Release archives: `EnderalTogetherReborn.zip` and `EnderalTogetherReborn-Client-v1.8.4.zip`.
* Committed (`534b7d2a`) and pushed to GitHub `origin/main`.
