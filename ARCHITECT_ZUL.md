# ZUL Framework: Architectural Decisions & Design Philosophy

This document outlines the core logic and design decisions behind the **Zomboid Unified Logging (ZUL)** framework, specifically addressing the unique challenges of the Project Zomboid (PZ) Lua environment.

## 1. Core Philosophy: Lazy & Dynamic

ZUL avoids "Push-based" configuration (where the framework tries to force settings onto mods). Instead, it uses **Dynamic Resolution**.

- **Decoupled State**: A logger instance (`ZUL.new("ModName")`) holds no fixed state about its log level.
- **JIT (Just-in-Time) Calculation**: Every time a log method is called, the framework calculates the "Effective Level" at that exact microsecond.
- **Order Independence**: This solves the "Mod Load Order" problem. Whether a mod loads before or after ZUL, the logging logic remains robust.

## 2. Solving the "Chicken and Egg" Problem (PZ Loading Order)

In Project Zomboid, Lua scripts are often parsed and executed before the game engine has populated `SandboxVars`.

### The Multi-Path Initialization

To ensure ZUL captures sandbox settings as early as possible without crashing, it uses a three-stage initialization in `ZUL_Init.lua`:

1.  **`OnGameBoot`**: The earliest possible hook. Usually too early for SandboxVars, but handles specialized environments or fast-loading components.
2.  **`OnInitGlobalModData`**: **The Primary Hook.** This is the earliest reliable point after the engine has bound Sandbox Options.
3.  **`OnInitWorld`**: The final fallback to ensure settings are active before the player enters the game world.

### Proactive Self-Healing

Every time a mod author calls `ZUL.new()`, the framework internally checks if settings are loaded. If the game engine just made them available, ZUL "snags" them immediately without waiting for the next event trigger.

## 3. Log Level Hierarchy (Sovereignty)

ZUL respects a strict order of operations to ensure both mod authors and server admins have control, with the author having the "final say" if they choose to use it.

**Effective Level Resolution (High to Low Priority):**

1.  **Mod Author Override**: If a mod calls `logger:setLevel("FATAL")`, ZUL respects this absolutely.
2.  **Sandbox Global Level**: If no manual level is set, ZUL checks if the mod is **Included** (or not **Excluded**) in sandbox settings.
3.  **Framework Default**: If the mod is excluded from sandbox control, it falls back to the safe default (`INFO`).

## 4. Performance & Engineering Notes

- **Diagnostic Guards**: Because PZ dynamically populates the `SandboxVars` table based on text files, static analyzers (like EmmyLua) see them as "undefined fields". ZUL uses specific suppression comments to maintain a clean linting environment while maintaining dynamic flexibility.
- **Call Overhead**: The "Lazy Initialization" inside `ZUL.new` uses a truthy-check guard. Once initialized, the overhead of this check is negligible (nanoseconds), making logger creation extremely cheap and safe to use in constructors.
- **Side-Safety**: ZUL identifies its execution context (Server/Client/Single-Player) dynamically, ensuring log prefixes correctly represent where the message originated.

## 5. Usage Best Practices

- **Alias your Loggers**: Always create a local logger at the top of your file: `local logger = ZUL.new("YourMod")`.
- **Metadata over Strings**: Use the context parameter `logger:info("Message", { key = val })` instead of string concatenation. This keeps logs structured and easier to parse in external tools.
