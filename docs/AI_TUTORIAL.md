# Making a Roblox game with AI (Antigravity + Studio MCP)

Built from Roblox's own guides, not ads:
- Build with a coding harness: https://create.roblox.com/docs/ai/build
- Build your first game with Assistant: https://create.roblox.com/docs/ai/build-with-assistant
- Studio MCP server: https://create.roblox.com/docs/studio/mcp
- Roblox starter repo + "How to write a CLAUDE.md": https://prod.docsiteassets.roblox.com/assets/solutions/WaveSurvival.zip
- DevForum "How to Develop with AI the Right Way": https://devforum.roblox.com/t/4856246
- Discovery signals: https://create.roblox.com/docs/discovery

The loop the whole tutorial uses: **plan -> build one small piece -> agent playtests via MCP -> you playtest -> commit**. Never skip the commit. Git is your undo button.

---

## Part 0. Who does what

| Job | Tool |
|---|---|
| Scripts (`src/`) | Antigravity agent |
| Running playtests, reading Output, inspecting game tree | Antigravity via Studio MCP |
| Map, parts, lighting, placing models | Studio by hand, or Assistant / MCP `generate_mesh` |
| Icons, thumbnails | Your image AI, uploaded via Asset Manager |
| Game design, balance, feel, final art call | You |

---

## Part 1. Setup (one time, ~30 min)

1. Install: Roblox Studio, Git, Antigravity (the **IDE**, not Antigravity Hub; Hub versions 2.4.3-2.8.0 have a reported MCP handshake bug with Studio).
2. Install Rojo for Windows: download `rojo-7.7.1-windows-x86_64.zip` from https://github.com/rojo-rbx/rojo/releases, put `rojo.exe` somewhere on PATH. In Studio install the Rojo plugin (`rojo plugin install` or from the Creator Store).
3. Clone the repo and open the folder in Antigravity:
   ```bash
   git clone https://github.com/RetakerMZ/roblox-simulator.git
   ```
4. Open `game.rbxl` in Studio. **File -> Save to File As** `game.rbxl` (keep working in that file).
5. Game Settings -> Security -> enable **Studio Access to API Services** (DataStore saves in Studio).
6. In the Antigravity terminal: `rojo serve`. In Studio, Rojo plugin -> **Connect**.
7. Studio MCP: open **Assistant** (top right) -> `⋯` -> **Manage MCP Servers** -> make sure MCP is enabled -> Quick connect -> **Antigravity**. Restart both apps if it doesn't show.
   If Quick connect fails, add this to Antigravity's MCP config (`⋯` -> MCP Servers -> Manage -> View raw config, `mcp_config.json`):
   ```json
   {
     "mcpServers": {
       "Roblox_Studio": {
         "command": "cmd.exe",
         "args": ["/c", "cd /d %LOCALAPPDATA%\\Roblox && .\\mcp.bat"]
       }
     }
   }
   ```
   Studio shows the exact config for your machine under Assistant Settings -> MCP Servers -> Setup instructions. Use that if it differs.
8. Verify, prompt Antigravity:
   > Use the Roblox Studio MCP to list what's in Workspace and ServerScriptService.

   You should see Baseplate, SpawnLocation, and `Server` with 5 services.
9. End-to-end check:
   > Start a playtest via MCP, read the Output, and tell me if "[Server] Roblox Simulator core services initialized" printed. Then stop the playtest.

10. Commit: `git add . && git commit -m "setup verified"`.

---

## Part 2. Give the agent memory

The agent forgets everything between chats. An `AGENTS.md` in the repo root is its rulebook: layout, which folders sync, code rules, workflow. Have the agent write it by interviewing you (Roblox's recommended way):

> I want to create an AGENTS.md for this Roblox project. Read default.project.json and src/, then ask me what you need: synced folders, MCP-only areas, file naming, working style, code rules. Then write the file.

Must include: Rojo-synced folders vs MCP-only areas (Workspace, StarterGui, Lighting), "never edit synced scripts in Studio", "server validates every OnServerEvent", "all tunables in Config.luau", "playtest via MCP after every change". Review it, then start a **new chat** so it gets loaded. Make Antigravity read it every task (Rules / Customizations, or start each chat with "Read AGENTS.md first").

Rule from Roblox's guide: **every time you correct the agent twice for the same thing, add a line to AGENTS.md.**

Rule from the DevForum post: document what the agent must **never assume** (e.g. "this function is called from X, don't delete it"), not only what the system does. That's how refactors silently break features.

---

## Part 3. Plan the game (no code yet)

Prompt:
> Read AGENTS.md and all files in src/. I want to turn this into a simulator where [YOUR THEME + ONE TWIST]. Don't write code yet. Break it into small phases, each testable on its own in under 5 minutes. For each phase list: files to change, what needs MCP (Workspace/GUI), and how I test it.

Read the plan. Cut anything not needed for the first 10 minutes of play. Changing the plan is cheap, changing code is not.

A good phase order for this repo:
1. World: spawn area + 1 zone + click pad (MCP / by hand)
2. Juice: number pop-ups, click sound, button tween
3. Pets follow the player (models in `ReplicatedStorage.Assets.Pets`)
4. Egg in the world with a hatch animation
5. Zone 2 gated by rebirths
6. Daily reward + playtime reward (return signals)
7. Gamepasses: 2x Clicks, Auto Click
8. Your AI icons + thumbnail

---

## Part 4. Build loop (repeat per phase)

1. `Implement phase N from the plan. Only touch the files listed.`
2. `Start a playtest via MCP, check Output for errors, fix them, stop the playtest. Tell me what you verified.`
3. **You** press Play and actually play it. MCP can catch errors; it can't tell you if it's fun.
4. Bug? Be specific: `When I click the egg I lose 250 clicks but no pet appears in the inventory.` Not `it doesn't work`.
5. Works -> `git add . && git commit -m "phase N: ..."`.

When stuck:
- Fix made it worse: `Undo that change.` (or `git checkout -- .`)
- Agent looping on bad fixes: `Stop fixing. Read every script involved and explain step by step what should happen and where it goes wrong.`
- Chat got long and dumb: start a new chat. AGENTS.md carries the context.

---

## Part 5. Models and assets

- Placeholder pets/props: `/generate_mesh low poly cute blue dragon pet` in Assistant, or ask Antigravity to call `generate_mesh` via MCP. Move/scale by hand after; don't re-prompt for positioning.
- Eggs, portals, shops: `/generate_procedural_model` (editable attributes).
- Surfaces: `/generate_material weathered stone`.
- Free filler (trees, rocks): MCP `search_asset` + `insert_asset`, or Toolbox.
- Icons: your image AI -> PNG -> Studio **Asset Manager** -> Import -> copy the asset ID -> prompt:
  > Replace the Hatch button with an ImageButton using rbxassetid://123456. Keep the click handler.
- Animation: not something code-gen does well. Use Animation Editor or Store animations.
- No copyrighted characters/names (Dragon Ball, Pokemon, etc.). You are liable, AI doesn't launder IP.

---

## Part 6. What the agent gets wrong (check these yourself)

- Trusting the client: remote handlers that accept an amount/price from the client. Every `OnServerEvent` must validate on the server.
- Deprecated APIs: `wait()`, `spawn()`, `BodyPosition`, `:connect`.
- DataStore without `pcall`, or saving every click (rate limits).
- Scripts in the wrong place (`.server.luau` in shared, client code in ServerScriptService).
- Giant files. Keep modules under ~300 lines.
- Deleting "unused" code that's actually called indirectly. Review diffs before committing.

---

## Part 7. Ship it

1. File -> Publish to Roblox. Set icon, thumbnail, description, genre.
2. Game Settings -> Monetization: create gamepasses, put IDs in `Config.luau`.
3. Get 10-20 real players (friends, Discord). Watch Creator Dashboard -> Analytics: D1 retention, playtime per user, first-play bounce. These feed Recommended For You (it now looks at 28 days).
4. Weekly update: one new zone or egg. Small and steady beats one huge update.

Ship the ugly version first. Polish what players actually play.
