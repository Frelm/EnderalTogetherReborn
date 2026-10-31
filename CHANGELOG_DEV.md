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

## 3. Active Investigation: Dungeon & Puzzle Synchronization

### 3.1 First Case: The Temple Columns / Skeleton Key Puzzle (`_00E_MQ00TemplePuzzleSCN`)
* **Symptom:** In the early temple ruins, when one player inserts the Temple Key (Skeleton Key) to raise stone columns/pillars, the columns only rise for the activating player. The remote player sees nothing happen.
* **Root Cause Found in Enderal Script:**
  * The puzzle is handled by `_00E_MQ00TemplePuzzleSCN.psc`.
  * Lines 4–6:
    ```papyrus
    Event OnActivate(ObjectReference akActionRef)
        Actor PlayerRef = Game.GetForm(0x14) as Actor
        if akActionRef == PlayerRef && !Activated && (PlayerRef.GetItemCount(_00E_MQ00TempleKey) >= 1)
    ```
  * In Skyrim Together:
    1. Player 1 activates the pedestal. Player 1 is `Game.GetForm(0x14)` on their machine, has the key, and triggers the animation/translation of linked columns.
    2. Player 1's client sends `ActivateRequest` to the server, which broadcasts `NotifyActivate` to Player 2.
    3. Player 2's client executes `pObject->Activate(pActor, 0, nullptr, 1, 0)` in `ObjectService::OnActivateNotify`, where `pActor` is **Player 1's remote actor**.
    4. On Player 2's machine, the Papyrus engine executes `OnActivate(akActionRef)`.
    5. On Player 2's machine, `PlayerRef = Game.GetForm(0x14)` evaluates to **Player 2**.
    6. Therefore, `akActionRef == PlayerRef` **FAILS**, and `PlayerRef.GetItemCount` also fails!
    7. As a result, the puzzle logic never executes on Player 2's game.

### 3.2 Meditation Synchronization Observation
* **Symptom:** When one player meditates to spend Memory Points, the other player is also transported to the meditation temple.
* **Root Cause Found:**
  * Meditating triggers `_00E_Class_Meditate` / `_00E_Class_OpenClassMenuSpell`.
  * `MagicService` replicates spell target additions across the network.
  * When Player 2 receives the magic effect, `_00E_Class_OpenClassMenuScript.psc` executes `PlayerREF.MoveTo(_00E_ClassMenuOrigin)`, where `PlayerREF` is the local player (`0x14`).
* **Design Decision:** Non-critical for now. Focus primarily on dungeon progression and puzzle synchronization.

---

## 4. Work In Progress & Next Steps
* [ ] Design a clean, robust solution for Enderal puzzle activators:
  * Pattern A: A companion `.esp` / Papyrus patch (`SkyrimTogetherEnderalPatches.esp` or patched `.pex` scripts) using `SkyrimTogetherUtils.IsPlayer(actorRef)` so both local and remote players can satisfy the activation condition.
  * Pattern B: Engine-level activation helper in `ObjectService.cpp`.
* [ ] Audit other common Enderal dungeon puzzles (pillar wheels, pressure plates, pull levers, barrier gates).
* [ ] Verify fix in-game with test instances.
