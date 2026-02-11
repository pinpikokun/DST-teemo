# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Don't Starve Together (DST) character mod — "Captain Teemo" (League of Legends character). Published on Steam Workshop (ID: 390684095). Written in Lua, interpreted directly by the DST game engine — no build step, no tests, no CI.

- **DST API version:** 10
- **Mod version:** 0.2.2.3
- **All clients require this mod** to play together

## Architecture

### Entry Points

- **modinfo.lua** — Mod metadata (name, version, compatibility flags)
- **modmain.lua** — Main entry point: loads assets, defines recipes, registers the character via `AddModCharacter("teemo", "MALE")`

### Scripts

- **scripts/prefabs/teemo.lua** — Character definition with three core mechanics:
  - *Camouflage* — invisibility after standing still 2+ seconds (sanity > 30%), grants speed boost
  - *Toxic Shot* — poison on attack (10 hit damage + 6/s DOT for 4 seconds)
  - *Starting inventory* setup
- **scripts/prefabs/blind_dart.lua** — Ranged weapon (blowgun-type), 10 uses, rechargeable with mushrooms via Trader component. Character-restricted to Teemo.
- **scripts/prefabs/noxious_trap.lua** — Deployable trap, 10-minute lifespan, AoE damage with slow debuff. PvP-aware activation logic.
- **scripts/prefabs/blind_effect.lua, explode_noxious_trap.lua, toxic_effect_by_teemo.lua** — Visual effect prefabs that attach to target entities as children
- **scripts/components/characterspecific.lua** — Restricts item equipping to Teemo only
- **scripts/components/explosive_noxious_trap.lua** — Handles trap explosion: AoE entity search, damage calculation by creature tag, slow debuff application
- **scripts/speech_teemo.lua** — Character dialogue strings (~46KB)

### Assets

- **anim/** — Animation ZIP archives (character, items, effects)
- **images/** — Texture (.tex) and atlas (.xml) pairs organized by UI context (portraits, avatars, inventory icons, HUD, map icons)
- **sound/** — FMOD sound bank (.fev + .fsb)

## DST Modding Patterns Used

**Prefab pattern:** Each game entity is a prefab defined by a `fn(Sim)` function that creates/configures an entity, returned via `Prefab("path/name", fn, assets)`.

**Component pattern:** Custom components use `Class(function(self, inst) ... end)` with methods defined as `ComponentName:Method()`.

**Server/client split:** `common_postinit` runs on all clients (visuals/UI), `master_postinit` runs on server only (game logic). Guard server-only code with `if not TheWorld.ismastersim then return inst end`.

**Event-driven:** Game logic responds to events (`inst:ListenForEvent("eventname", callback)`). Common events: `equipped`, `onattackother`, `attacked`, `death`.

**Task system:** `inst:DoPeriodicTask(interval, fn)` for repeating logic, `inst:DoTaskInTime(delay, fn)` for delayed execution. Cancel with `task:Cancel()`.

## Notes

- Comments are mixed English and Japanese
- Some files contain large blocks of commented-out reference code (e.g., spawn FX list in noxious_trap.lua)
