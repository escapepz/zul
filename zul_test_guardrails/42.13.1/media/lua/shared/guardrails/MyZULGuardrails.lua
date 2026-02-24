-- MyZULGuardrails.lua
-- Goal: Demonstrate how to extend ZUL with guardrails using hooks (function wrapping)
-- without modifying the core ZUL.lua file.

local MODULE_NAME = "MyZULGuardrails"

-- 1. Define Guardrail Logic

local DENY_KEYS = {
    modData = true,
    inventory = true,
    knownRecipes = true,
}

--- Truncates large tables and removes sensitive keys
--- @param ctx table
--- @param maxKeys number? Default 20
--- @return table
local function safeContext(ctx, maxKeys)
    if type(ctx) ~= "table" then return ctx end
    maxKeys = maxKeys or 20

    local out = {}
    local count = 0
    for k, v in pairs(ctx) do
        ---@diagnostic disable-next-line: unnecessary-if
        if not DENY_KEYS[k] then
            count = count + 1
            if count > maxKeys then
                out._truncated = true
                out._keys = count -- This will be slightly inaccurate as it stops counting
                break
            end
            -- Recursively apply if it's a small sub-table?
            -- For simplicity and performance, we'll just handle one level here or shallow-copy.
            out[k] = v
        end
    end
    return out
end

-- 2. Hooking Engine
local function applyHooks()
    local hasZUL, ZUL = pcall(require, "zul")
    if not hasZUL or type(ZUL) ~= "table" or not ZUL.serialize then
        print("[" .. MODULE_NAME .. "] ZUL not found or invalid! Hooks not applied.")
        return
    end

    if ZUL._guardrailsApplied then return end

    local originalSerialize = ZUL.serialize

    --- Wrapped serialize that applies guardrails first
    --- @param val any
    --- @return string
    ZUL.serialize = function(val)
        if type(val) == "table" then
            -- Apply guardrails before serialization
            val = safeContext(val)
        end
        return originalSerialize(val)
    end

    -- 3. Extension Helpers (Optional)

    --- Helper for level-aware payload suppression
    --- Use this for heavy data that should ONLY be logged at TRACE level
    function ZUL.traceHeavy(logger, action, payload)
        if logger:isLoggingEnabled(ZUL.Level.TRACE) then
            logger:trace(action, payload)
        else
            logger:debug(action, {
                _heavy_data = "suppressed",
                _hint = "Enable TRACE to see full payload"
            })
        end
    end

    ZUL._guardrailsApplied = true
    print("[" .. MODULE_NAME .. "] ZUL Guardrails: Applied (ZUL.serialize hooked, safeContext and sanitize enabled)")
end

-- 4. Execution Logic (Delay for Project Zomboid, immediate for tests)

---@diagnostic disable-next-line: unnecessary-if
if Events and Events.OnGameBoot then
    Events.OnGameBoot.Add(applyHooks)
else
    -- Fallback for mock environments or manual loading
    applyHooks()
end
