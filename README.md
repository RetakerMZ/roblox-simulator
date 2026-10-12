# Roblox Simulator Core Engine

Production-grade core architecture for a modern Roblox simulator game (inspired by mechanics in *Pet Simulator 99* and *Arm Wrestle Simulator*).

Built for local Luau development using **Rojo** and AI-assisted coding workflows (**Claude Code**, **Hermes**, **Codex**).

---

## Architecture Overview

```text
roblox-simulator/
├── default.project.json       # Rojo DataModel mapping
├── game.rbxl                  # Pre-built playable Roblox place file
└── src/
    ├── shared/
    │   ├── Config.luau        # Formulas, egg odds, rebirth multipliers, costs
    │   ├── Network.luau       # Remote events / functions factory
    │   └── Types.luau         # Luau type definitions
    ├── server/
    │   ├── init.server.luau   # Server bootstrap
    │   ├── DataService.luau   # DataStore persistence + leaderstats
    │   ├── ClickService.luau  # Debounced click logic + multiplier stacking
    │   ├── EggService.luau    # Weighted gacha rolls & pet inventory
    │   ├── RebirthService.luau# Rebirth resets & permanent multipliers
    │   └── UpgradeService.luau# Power progression tier upgrades
    └── client/
        ├── init.client.luau   # Client bootstrap
        ├── ClickController.luau# Input & tap detection
        └── UIController.luau  # Code-driven ScreenGui HUD & inventory
```

---

## How to Run

### Method 1: Instant Play in Roblox Studio (No Setup)
1. Open `game.rbxl` directly with **Roblox Studio**.
2. Press **Play (F5)**.
3. Everything works out of the box (clicks, egg hatching, rebirths, leaderstats, UI).

### Method 2: Rojo Live Development
1. Install Rojo:
   ```bash
   cargo install rojo
   # or download binary from https://github.com/rojo-rbx/rojo/releases
   ```
2. Start the Rojo sync server:
   ```bash
   rojo serve
   ```
3. In Roblox Studio, install the **Rojo Plugin** from the Toolbox/Plugins tab.
4. Click **Connect** in the Rojo Studio plugin. Any edit to `src/` automatically updates Studio in real time.

---

## Core Simulator Formulas

* **Click Calculation:**
  $$\text{Gain} = \max(1, \lfloor \text{UpgradeLevel} \times \prod(\text{EquippedPetMultipliers}) \times (1 + \text{Rebirths} \times 0.5) \rfloor$$
* **Rebirth Cost:**
  $$\text{Cost} = \lfloor 1000 \times 2.5^{\text{Rebirths}} \rfloor$$
* **Upgrade Cost:**
  $$\text{Cost} = \lfloor 50 \times 1.8^{\text{Level} - 1} \rfloor$$

---

## Expanding with Claude Code / AI Agents

When prompting Claude Code to build features, provide the module boundaries:

### Example: Adding a Trade System
> "Read `src/shared/Types.luau` and `src/server/DataService.luau`. Create `src/server/TradeService.luau` and `src/client/TradeController.luau` using `Network.luau` remotes. Validate ownership server-side, lock trade state for both players before swap, and commit via `DataService`."

### Example: Adding Zones & Portals
> "Add a `Zones` table in `Config.luau` gated by `Rebirths`. Create `src/server/ZoneService.luau` that checks player touch events on portal parts and verifies rebirth tier before teleporting."

---

## Asset Customization (AI Icons & Models)
* **HUD Buttons:** `src/client/UIController.luau` uses native Roblox GUI elements. To use AI-generated images, swap `Instance.new("TextButton")` with `Instance.new("ImageButton")` and set `Image = "rbxassetid://<AssetID>"`.
* **Pet Models:** Pet data contains `Id`, `Name`, `Rarity`, `Multiplier`. To display 3D models following the player, drop pet models into `ReplicatedStorage.Assets.Pets.<Name>` and clone them with an AlignPosition/AlignOrientation constraint on player spawn.
