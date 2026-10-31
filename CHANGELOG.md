# Changelog

All notable changes to Enderal Together Reborn will be documented in this file.

## [v1.8.4] - Enderal Special Edition Port & Fixes

### Added
- Support for *Enderal: Forgotten Stories (Special Edition)* on engine runtime 1.7.104.0.
- Pinned network protocol version matching for dedicated servers (`v1.8.4`).
- Exploration & Combat co-op mode enabled by default (`bDisableQuestSync = true`).

### Fixed
- **Temple Column / Skeleton Key Puzzle (`_00E_MQ00TemplePuzzleSCN`):**
  - Resolved an issue where lifting the columns in the early temple ruins only animated for the activating player. Both local and remote activations now correctly trigger the stone translation.
- **Meditation Worldspace Teleport (`_00e_class_openclassmenuscript`):**
  - Added a caster guard so meditating to spend Memory Points only transports the player who activated it, leaving party members undisturbed.
- **Dungeon Lifts & Elevators (`_00e_dungeonliftscript`):**
  - Moving platforms and elevator chains now trigger and move simultaneously across all clients.
- **Temple Exit Door (`_00e_mqp03_exitdoorscript`):**
  - Synchronized exit door activation so either player can advance the stage.
- **Registry & Profile Isolation:**
  - Isolated registry paths under `Enderal Special Edition` to prevent collisions with vanilla Skyrim SE.
- **Engine Stability:**
  - Added null-pointer safety checks for missing vanilla globals (`WorldEventsEnabled`, `KillMove`).
  - Blacklisted core Enderal background and progression quests to avoid desyncing story cutscenes and leveling.
  - Bundled pre-configured `EngineFixes.toml` disabling memory allocator overrides that caused crashes on actor spawn.
  - Resolved packet opcode alignment between client and dedicated server.
