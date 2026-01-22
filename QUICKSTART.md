# ZUL Quick Start Guide

Get started with ZUL (Zomboid Unified Logging) in 5 minutes!

## Installation

1. **Subscribe on Steam Workshop** (when published) or copy to your mods folder
2. **Enable the mod** in Project Zomboid's mod menu
3. **Start using it** in your mod!

## Basic Usage (Copy & Paste)

```lua
-- Add this to the top of your Lua file
local ZUL = require "ZUL"
local logger = ZUL.new("YourModName")

-- Now you can log!
logger:info("Your message here") -- Goes to mod log file
logger:log("Direct console log") -- Prints directly to console
```

## Common Patterns

### 1. Simple Message
```lua
logger:info("Player spawned")
```

### 2. Message with Data
```lua
logger:debug("Processing items", { count = 10, type = "weapon" })
```

### 3. Error Logging
```lua
logger:error("Failed to load config", { reason = "File not found" })
```

### 4. Different Log Levels
```lua
logger:trace("Very detailed info")  -- Most verbose
logger:debug("Debug info")
logger:info("Important event")      -- Default level
logger:warn("Warning!")
logger:error("Error occurred")
logger:fatal("Critical failure")    -- Least verbose

-- Direct Console Output (bypasses writeLog)
logger:log("Quick debug message")   -- Uses print()
```

## Setting Log Levels

### In Your Code
```lua
local ZUL = require "ZUL"

-- Set level for your mod
ZUL.setLevel("YourModName", "DEBUG")

-- Or use the child logger
local logger = ZUL.new("YourModName")
logger:setLevel("DEBUG")
```

### Via Sandbox Options (In-Game)

1. Start a new game or load a save
2. Go to **Sandbox Options**
3. Find **ZUL - Zomboid Unified Logging** section
4. Set your preferences:
   - **Global Log Level**: Choose from TRACE to FATAL
   - **Include Mods**: List mods to apply settings to (optional)
   - **Exclude Mods**: List mods to ignore (optional)

## Log Levels Explained

| Level | When to Use | Example |
|-------|-------------|---------|
| TRACE | Loop iterations, very detailed debugging | `logger:trace("Processing item", i)` |
| DEBUG | Function calls, data processing | `logger:debug("Loading config")` |
| INFO | Important events, initialization | `logger:info("Mod initialized")` |
| WARN | Warnings, deprecated usage | `logger:warn("Slow operation")` |
| ERROR | Errors, failed operations | `logger:error("Failed to save")` |
| FATAL | Critical failures | `logger:fatal("Cannot continue")` |
| (log) | Quick debugging, direct console output | `logger:log("Test message")` |

## Complete Example

```lua
-- MyAwesomeMod.lua
local ZUL = require "ZUL"
local logger = ZUL.new("MyAwesomeMod")

-- Optional: Set log level during development
logger:setLevel("DEBUG")

local function init()
    logger:info("MyAwesomeMod initialized")
    logger:debug("Version", { version = "1.0.0" })
end

local function onPlayerSpawn(player)
    logger:info("Player spawned", {
        username = player:getUsername(),
        profession = player:getDescriptor():getProfession()
    })
end

local function onPlayerDeath(player)
    logger:warn("Player died", {
        username = player:getUsername(),
        zombieKills = player:getZombieKills()
    })
end

-- Initialize
Events.OnGameBoot.Add(init)
Events.OnPlayerSpawn.Add(onPlayerSpawn)
Events.OnPlayerDeath.Add(onPlayerDeath)
```

## Viewing Logs

Logs are written to Project Zomboid's log files:

**Location**: `C:\Users\<YourName>\Zomboid\Logs\`

**Files**:
- `YourModName.txt` - Your mod's log file
- `console.txt` - General console output

## Tips

✅ **DO**:
- Use appropriate log levels
- Include useful context data
- Create one logger per mod
- Use structured logging (pass objects)

❌ **DON'T**:
- Log in tight loops (use TRACE level)
- Log sensitive data (passwords, tokens)
- Create multiple loggers for the same mod
- Concatenate strings manually (use context parameter)

## Need Help?

- 📖 **Full Documentation**: See `README.md`
- 💡 **More Examples**: See `EXAMPLES.md`
- 🐛 **Issues**: Report on GitHub
- ☕ **Support**: https://ko-fi.com/escapepz

## Next Steps

1. ✅ Install ZUL
2. ✅ Add `local ZUL = require "ZUL"` to your mod
3. ✅ Create a logger: `local logger = ZUL.new("YourMod")`
4. ✅ Start logging: `logger:info("Hello World!")`
5. 🎉 You're done!

---

**Happy Logging!** 🪵
