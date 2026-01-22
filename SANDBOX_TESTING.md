# Testing ZUL Sandbox Options

This guide provides instructions for verifying the `IncludeMods` and `ExcludeMods` sandbox settings in ZUL.

## Preparation
1. Open Project Zomboid.
2. Go to **Host** -> **Manage Settings** -> **Sandbox Options**.
3. Locate the **ZUL** section.

---

## Scenario 1: IncludeMods Filtering
*Verifies that ONLY listed mods are affected by the global log level.*

### Setup
1. **Global Log Level**: Set to `TRACE` (Level 1).
2. **Include Mods**: Set to `TargetMod`.
3. **Exclude Mods**: Leave empty.

### Execution
Run the following Lua code (e.g., via a test file or console):
```lua
local ZUL = require "ZUL"
local target = ZUL.new("TargetMod")
local other = ZUL.new("OtherMod")

print("--- Testing IncludeMods ---")
target:trace("TargetMod: This SHOULD appear (TRACE enabled via Include)")
other:trace("OtherMod: This should NOT appear (Still INFO)")
```

### Expected Result
- The console shows `[TRACE] TargetMod: This SHOULD appear`.
- The console does **not** show the `OtherMod` trace message.

---

## Scenario 2: ExcludeMods Filtering
*Verifies that specific mods can opt-out of the global settings.*

### Setup
1. **Global Log Level**: Set to `TRACE` (Level 1).
2. **Include Mods**: Leave empty (defaults to Apply All).
3. **Exclude Mods**: Set to `NoisyMod`.

### Execution
```lua
local ZUL = require "ZUL"
local normal = ZUL.new("NormalMod")
local noisy = ZUL.new("NoisyMod")

print("--- Testing ExcludeMods ---")
normal:trace("NormalMod: This SHOULD appear")
noisy:trace("NoisyMod: This should NOT appear (Excluded)")
```

### Expected Result
- The console shows `[TRACE] NormalMod: This SHOULD appear`.
- The console does **not** show the `NoisyMod` trace message.

---

## Scenario 3: Exclude Precedence
*Verifies that Exclude takes priority over Include.*

### Setup
1. **Global Log Level**: Set to `TRACE`.
2. **Include Mods**: Set to `ConflictedMod`.
3. **Exclude Mods**: Set to `ConflictedMod`.

### Execution
```lua
local ZUL = require "ZUL"
local log = ZUL.new("ConflictedMod")

print("--- Testing Precedence ---")
log:trace("ConflictedMod: This should NOT appear (Exclude wins)")
```

### Expected Result
- No trace message appears for `ConflictedMod`.

---

## Scenario 4: ZUL Self-Exclusion
*Verifies that the ZUL framework itself is never affected by sandbox filters.*

### Setup
1. **Global Log Level**: Set to `ERROR`.
2. **Include Mods**: Set to `SomeOtherMod`.

### Execution
```lua
local ZUL = require "ZUL"
local logger = ZUL.new("ZUL")
logger:info("ZUL Info message")
```

### Expected Result
- The message **SHOULD** appear even though levels are set to ERROR and ZUL is not in the Include list, because the framework always uses the default level for its own internal logging to ensure availability.

---

## How to Verify
- **Terminal**: Check the game terminal window for real-time output.
- **Logs**: Check `C:\Users\<User>\Zomboid\Logs\console.txt`.
