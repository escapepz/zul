# ZUL - Zomboid Unified Logging

**Version: 1.1.0**

A unified logging framework for Project Zomboid mods with multi-level logging support, child loggers, and configurable sandbox options.

## 📚 Documentation

- [Quick Start Guide](docs/QUICKSTART.md) — Get started in 5 minutes
- [Usage Examples](docs/EXAMPLES.md) — Practical code snippets and patterns
- [Architectural Decisions](docs/ARCHITECT_ZUL.md) — Design philosophy and lifecycle details
- [Sandbox Testing Guide](docs/SANDBOX_TESTING.md) — How to verify settings in-game
- [Integration Test Protocol](docs/TEST.md) — Step-by-step verification flow
- [Benchmark Results](benchmark/RESULT.md) — Performance benchmarks and stress test results
- [Implementation Summary](docs/IMPLEMENTATION_SUMMARY.md) — Technical overview of the framework

## Features

- **Multi-Level Logging**: TRACE, DEBUG, INFO, WARN, ERROR, FATAL (via `writeLog`)
- **Direct Console Logging**: `.log()` method for immediate `print()` output
- **Sandbox Options**: Configure global log levels and mod filtering via in-game settings
- **Server/Client Identification**: Automatic side detection in logs ([SERVER], [CLIENT], [SINGLE_PLAYER])
- **Structured Logging**: Support for context objects and details
- **Include/Exclude Lists**: Fine-grained control over which mods use ZUL settings
- **Pino/Winston-inspired API**: Familiar logging patterns for JavaScript developers

## Installation

1. Subscribe to the mod on Steam Workshop (or download manually)
2. Enable the mod in your Project Zomboid mod list
3. Configure sandbox options (optional) before starting a new game

## Quick Start

### Basic Usage

```lua
local ZUL = require "ZUL"
local logger = ZUL.new("MyMod")

-- Simple logging
logger:info("Player entered RV")
logger:warn("Low health detected")
logger:error("Failed to load config")

-- Logging with context
logger:debug("Processing player data", { playerId = 123, health = 50 })

-- Structured logging with action:phase pattern
logger:trace("Database", "Query", { table = "players", rows = 10 })
```

### Log Levels

ZUL supports 6 log levels (from most to least verbose):

- **TRACE** (10): Very detailed debugging information
- **DEBUG** (20): Debugging information
- **INFO** (30): Informational messages (default)
- **WARN** (40): Warning messages
- **ERROR** (50): Error messages
- **FATAL** (60): Fatal error messages

### Setting Log Levels Programmatically

```lua
local ZUL = require "ZUL"

-- Set log level for a specific mod
ZUL.setLevel("MyMod", "DEBUG")
ZUL.setLevel("AnotherMod", ZUL.Level.TRACE)

-- Using child logger
local logger = ZUL.new("MyMod")
logger:setLevel("WARN") -- Only show WARN and above

-- Disable logging entirely for a mod
ZUL.setLevel("NoisyMod", ZUL.Level.NONE)
```

## Sandbox Options

ZUL provides three sandbox options for server administrators:

### Global Log Level

Sets the default log level for all mods using ZUL. This applies to:

- All mods if the Include list is empty
- Only mods in the Include list (if specified)
- Does NOT apply to mods in the Exclude list

**Options**: TRACE, DEBUG, INFO (default), WARN, ERROR, FATAL

### Include Mods

Comma-separated list of mod names to apply ZUL sandbox settings to.

**Example**: `MyMod,AnotherMod,ThirdMod`

**Behavior**:

- If empty: Settings apply to ALL mods (except excluded ones)
- If specified: Settings apply ONLY to listed mods

### Exclude Mods

Comma-separated list of mod names to exclude from ZUL sandbox settings.

**Example**: `NoisyMod,DebugMod`

**Behavior**:

- These mods will use their own programmatically set log levels
- Exclude list takes precedence over Include list

## Advanced Usage

### Custom Log Implementation

You can override how ZUL handles level-specific logging (TRACE, DEBUG, INFO, WARN, ERROR, FATAL). Note that `.log()` bypasses this and always uses `print()`.

```lua
local ZUL = require "ZUL"

-- Custom log handler (e.g., send to external service)
function ZUL.logImpl(modName, fullMessage)
    -- Default behavior
    writeLog(modName, fullMessage)

    -- Custom behavior
    sendToExternalLogger(modName, fullMessage)
end
```

### Checking Effective Log Level

```lua
local logger = ZUL.new("MyMod")

local currentLevel = logger:getEffectiveLevel()
print("Current log level: " .. currentLevel)

-- Check if a specific level is enabled
if ZUL.isLoggingEnabled("MyMod", ZUL.Level.DEBUG) then
    -- Perform expensive debug operation
    local debugData = collectDebugInfo()
    logger:debug("Debug info", debugData)
end
```

### Structured Logging

```lua
local logger = ZUL.new("MyMod")

-- Log with context object
logger:info("Player action", {
    action = "craft",
    item = "axe",
    duration = 5.2
})

-- Log with action:phase:details pattern
logger:debug("RV", "Entry", {
    vehicleId = "rv_001",
    playerId = 123,
    roomId = 5
})
```

## Migration from SharedLogger

If you were using the previous `SharedLogger` module:

1. Update your require statement:

   ```lua
   -- Old
   local SharedLogger = require "utils/SharedLogger"

   -- New
   local ZUL = require "ZUL"
   ```

2. Update all references from `SharedLogger` to `ZUL`:

   ```lua
   -- Old
   local logger = SharedLogger.new("MyMod")

   -- New
   local logger = ZUL.new("MyMod")
   ```

3. The API is fully backward compatible - no other changes needed!

## API Reference

### Module Constants

- `ZUL.Level` - Table containing numeric log levels:
  - `TRACE` (10)
  - `DEBUG` (20)
  - `INFO` (30)
  - `WARN` (40)
  - `ERROR` (50)
  - `FATAL` (60)
  - `NONE` (100) - Disables logging for the mod

### Module Functions

- `ZUL.new(modName)` - Create a child logger for a mod
- `ZUL.setLevel(modName, level)` - Set log level for a mod
- `ZUL.getEffectiveLevel(modName)` - Get current log level for a mod
- `ZUL.isLoggingEnabled(modName, level)` - Check if logging is enabled for a mod
- `ZUL.shouldApplySandboxSettings(modName)` - Check if sandbox logic applies to a mod
- `ZUL.resolveLevel(level)` - Convert level name to numeric value
- `ZUL.loadSandboxOptions(force)` - Load/refresh sandbox options (called automatically)
- `ZUL.serialize(val)` - Convert tables/values to strings for logging (internal helper)

### Child Logger Methods

- `logger:trace(message, context, details)` - Log at TRACE level
- `logger:debug(message, context, details)` - Log at DEBUG level
- `logger:info(message, context, details)` - Log at INFO level
- `logger:warn(message, context, details)` - Log at WARN level
- `logger:error(message, context, details)` - Log at ERROR level
- `logger:fatal(message, context, details)` - Log at FATAL level
- `logger:log(message, context, details)` - Log directly to console via `print()` (bypasses `ZUL.logImpl`)
- `logger:setLevel(level)` - Set log level for this logger's mod
- `logger:getEffectiveLevel()` - Get effective log level
- `logger:isLoggingEnabled(level)` - Check if a specific level is enabled for this logger

## Examples

### Example 1: Basic Mod Logging

```lua
local ZUL = require "ZUL"
local logger = ZUL.new("MyAwesomeMod")

local function onPlayerDeath(player)
    logger:warn("Player died", {
        username = player:getUsername(),
        location = player:getX() .. "," .. player:getY()
    })
end

Events.OnPlayerDeath.Add(onPlayerDeath)
```

### Example 2: Conditional Debug Logging

```lua
local ZUL = require "ZUL"
local logger = ZUL.new("PerformanceMod")

local function expensiveOperation()
    if ZUL.isLoggingEnabled("PerformanceMod", ZUL.Level.DEBUG) then
        local startTime = os.clock()
        -- ... do work ...
        local elapsed = os.clock() - startTime
        logger:debug("Operation completed", { duration = elapsed })
    end
end
```

### Example 3: Multi-Module Logging

```lua
-- ModuleA.lua
local ZUL = require "ZUL"
local logger = ZUL.new("MyMod")

function ModuleA.init()
    logger:info("Module A initialized")
end

-- ModuleB.lua
local ZUL = require "ZUL"
local logger = ZUL.new("MyMod")

function ModuleB.init()
    logger:info("Module B initialized")
end

-- Both modules share the same log level settings
```

## Initialization Lifecycle

Project Zomboid's Lua environment initializes in stages. ZUL uses a multi-stage approach to ensure settings are captured as early as possible while remaining robust in multiplayer environments where sandbox settings are synchronized after boot.

### Stage 1: Boot (Early)

During `OnGameBoot`, ZUL makes its first attempt to load settings. This catches mods that initialize very early. In Multiplayer, this will likely use local/default settings.

### Stage 2: Sync (Mid)

ZUL hooks into `OnInitGlobalModData`, `OnInitWorld`, `OnGameStart`, and `OnServerStarted` with a **force refresh** flag.

- As soon as the server sends the synchronized `SandboxVars` packet, ZUL will update its internal configuration.
- You will see `ZUL sandbox settings refreshed (Server Sync)` in the TRACE logs when this occurs.

### Effect on Early Logging

Mods that log _during_ the early boot sequence (before Stage 2) may use the framework's default levels (`INFO`) or local settings until the server sync completes. Once synchronized, all subsequent logs will respect the server's sandbox configuration.

## Support

- **Ko-fi**: [https://ko-fi.com/escapepz](https://ko-fi.com/escapepz)
- **GitHub**: [https://github.com/escapepz](https://github.com/escapepz)

## License

Created by eScape (@escapepz)

## Changelog

### Version 1.1.0

- **Multiplayer Sync Fix**: Implemented staged initialization with forced re-syncs to handle server Sandbox synchronization lag.
- **Improved Logging**: Added state-aware initialization logs (First-time vs Refresh).
- **Hardened Events**: Added `OnGameStart` and `OnServerStarted` as final initialization safety nets.
- **Enhanced Guarding**: Improved state management during the complex PZ startup sequence.

### Version 1.0.0

- Initial release
- Multi-level logging support
- Child logger API
- Sandbox options integration
- Include/exclude mod filtering
