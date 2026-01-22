-- @author eScape <https://github.com/escapepz/ZUL>

-- ZUL.lua (Zomboid Unified Logging)
-- A unified logging framework for Project Zomboid mods
-- Features: Multi-level logging, child loggers, sandbox options integration
-- Inspired by pino/winston for Lua/Project Zomboid

local ZUL = {}

-- Log Levels
ZUL.Level = {
	TRACE = 10,
	DEBUG = 20,
	INFO = 30,
	WARN = 40,
	ERROR = 50,
	FATAL = 60,
	NONE = 100
}

-- Level names for formatting
local LevelNames = {
	[10] = "TRACE",
	[20] = "DEBUG",
	[30] = "INFO",
	[40] = "WARN",
	[50] = "ERROR",
	[60] = "FATAL"
}

-- Registry for mod-specific log levels
ZUL.modLevels = {}
ZUL.defaultLevel = ZUL.Level.INFO

-- Sandbox options cache
ZUL.sandboxOptions = {
	globalLogLevel = nil,
	includeMods = {},
	excludeMods = {},
	loaded = false
}

--- Default logging implementation (can be redefined by external mods)
--- @param modName string Name of the mod
--- @param fullMessage string Pre-formatted log message
function ZUL.logImpl(modName, fullMessage)
	writeLog(modName, fullMessage)
end

--- Resolve a level name (string) to its numeric value
--- @param level string | number
--- @return number
function ZUL.resolveLevel(level)
	if type(level) == "number" then return level end
	if type(level) == "string" then
		return ZUL.Level[level:upper()] or ZUL.Level.INFO
	end
	return ZUL.Level.INFO
end

--- Load sandbox options and apply settings
function ZUL.loadSandboxOptions()
	---@diagnostic disable-next-line: unnecessary-if
	if ZUL.sandboxOptions.loaded then return end

	local sandboxVars = SandboxVars
	---@diagnostic disable-next-line: undefined-field
	if not sandboxVars or not sandboxVars.ZUL then
		-- Sandbox options not available yet, use defaults
		return
	end

	-- Verify we actually have values (sometimes SandboxVars exist but are empty during early boot)
	---@diagnostic disable-next-line: undefined-field
	local globalLevel = sandboxVars.ZUL.GlobalLogLevel
	if globalLevel == nil then
		return
	end

	-- Load global log level
	-- Convert sandbox option index to log level
	-- 1=TRACE, 2=DEBUG, 3=INFO, 4=WARN, 5=ERROR, 6=FATAL
	local levelMap = {
		[1] = ZUL.Level.TRACE,
		[2] = ZUL.Level.DEBUG,
		[3] = ZUL.Level.INFO,
		[4] = ZUL.Level.WARN,
		[5] = ZUL.Level.ERROR,
		[6] = ZUL.Level.FATAL
	}
	ZUL.sandboxOptions.globalLogLevel = levelMap[globalLevel] or ZUL.Level.INFO

	-- Parse include mods list
	---@diagnostic disable-next-line: undefined-field
	local includeMods = sandboxVars.ZUL.IncludeMods or ""
	if includeMods and includeMods ~= "" then
		for modName in string.gmatch(includeMods, "([^,]+)") do
			local trimmed = modName:match("^%s*(.-)%s*$") -- Trim whitespace
			if trimmed ~= "" then
				ZUL.sandboxOptions.includeMods[trimmed] = true
			end
		end
	end

	-- Parse exclude mods list
	---@diagnostic disable-next-line: undefined-field
	local excludeMods = sandboxVars.ZUL.ExcludeMods or ""
	if excludeMods and excludeMods ~= "" then
		for modName in string.gmatch(excludeMods, "([^,]+)") do
			local trimmed = modName:match("^%s*(.-)%s*$") -- Trim whitespace
			if trimmed ~= "" then
				ZUL.sandboxOptions.excludeMods[trimmed] = true
			end
		end
	end

	ZUL.sandboxOptions.loaded = true
end

--- Check if a mod should use ZUL sandbox settings
--- @param modName string
--- @return boolean
function ZUL.shouldApplySandboxSettings(modName)
	-- Always exclude ZUL itself from sandbox settings
	if modName == "ZUL" then return false end

	-- If mod is in exclude list, don't apply settings
	if ZUL.sandboxOptions.excludeMods[modName] then
		return false
	end

	-- If include list is empty, apply to all (except excluded)
	local hasIncludeList = false
	for _ in pairs(ZUL.sandboxOptions.includeMods) do
		hasIncludeList = true
		break
	end

	if not hasIncludeList then
		return true
	end

	-- If include list exists, only apply to mods in the list
	return ZUL.sandboxOptions.includeMods[modName] == true
end

--- Set the log level for a specific mod
--- @param modName string
--- @param level string | number (from ZUL.Level)
function ZUL.setLevel(modName, level)
	ZUL.modLevels[modName] = ZUL.resolveLevel(level)
end

--- Get the current log level for a mod
--- @param modName string
--- @return number
function ZUL.getEffectiveLevel(modName)
	-- Check if mod has a specific level set
	if ZUL.modLevels[modName] then
		return ZUL.modLevels[modName]
	end

	---@diagnostic disable-next-line: unnecessary-if
	-- Try to load sandbox options if not loaded yet
	if not ZUL.sandboxOptions.loaded then
		ZUL.loadSandboxOptions()
	end

	---@diagnostic disable-next-line: unnecessary-if
	-- Apply sandbox settings if applicable
	if ZUL.shouldApplySandboxSettings(modName) and ZUL.sandboxOptions.globalLogLevel then
		return ZUL.sandboxOptions.globalLogLevel
	end

	return ZUL.defaultLevel
end

--- Check if logging is enabled for a given mod and level
--- @param modName string Name of the mod
--- @param level number Level to check
--- @return boolean: true if logging should proceed, false to skip
function ZUL.isLoggingEnabled(modName, level)
	level = level or ZUL.Level.INFO
	return level >= ZUL.getEffectiveLevel(modName)
end

-- Internal helper to get side identification
local function getSide()
	if isServer() then
		return "[SERVER]"
	elseif isClient() then
		return "[CLIENT]"
	elseif not isMultiplayer() then
		return "[SINGLE_PLAYER]"
	else
		return "[UNKNOWN]"
	end
end

--- Serialize a value to string, handling tables recursively
--- @param val any
--- @return string
function ZUL.serialize(val)
	if type(val) ~= "table" then
		return tostring(val)
	end

	local parts = {}
	for k, v in pairs(val) do
		local kStr = type(k) == "string" and k or "[" .. tostring(k) .. "]"
		local vStr
		if type(v) == "table" then
			vStr = "{...}" -- Shallow for now to prevent infinite loops/too long logs
		else
			vStr = tostring(v)
		end
		table.insert(parts, kStr .. "=" .. vStr)
	end
	return "{" .. table.concat(parts, ", ") .. "}"
end

--- Internal logger engine
--- @param level number
--- @param modName string
--- @param message string | table
--- @param context any
--- @param details any
--- @param usePrint boolean If true, use print() instead of ZUL.logImpl
local function _log(level, modName, message, context, details, usePrint)
	if not ZUL.isLoggingEnabled(modName, level) then
		return
	end

	local side = getSide()
	local levelName = LevelNames[level] or "LOG"
	local fullMessage

	-- Handle table as first message (structured log attempt)
	if type(message) == "table" then
		fullMessage = string.format("%s [%s] %s", side, levelName, ZUL.serialize(message))
		-- Handle 4-param signature: action, phase, details
	elseif details then
		fullMessage = string.format("%s [%s] [%s:%s] %s", side, levelName, message, context,
			ZUL.serialize(details))
		-- Handle 3-param signature: message with context
	elseif context then
		if type(context) == "table" then
			fullMessage = string.format("%s [%s] %s - %s", side, levelName, message, ZUL.serialize(context))
		else
			fullMessage = string.format("%s [%s] %s %s", side, levelName, message, tostring(context))
		end
		-- Handle 2-param signature: simple message
	else
		fullMessage = string.format("%s [%s] %s", side, levelName, tostring(message))
	end

	if usePrint then
		print(fullMessage)
	else
		ZUL.logImpl(modName, fullMessage)
	end
end

-- Level-specific Shorthands

function ZUL.trace(modName, message, context, details)
	_log(ZUL.Level.TRACE, modName, message, context, details, false)
end

function ZUL.debug(modName, message, context, details)
	_log(ZUL.Level.DEBUG, modName, message, context, details, false)
end

function ZUL.info(modName, message, context, details)
	_log(ZUL.Level.INFO, modName, message, context, details, false)
end

function ZUL.warn(modName, message, context, details)
	_log(ZUL.Level.WARN, modName, message, context, details, false)
end

function ZUL.error(modName, message, context, details)
	_log(ZUL.Level.ERROR, modName, message, context, details, false)
end

function ZUL.fatal(modName, message, context, details)
	_log(ZUL.Level.FATAL, modName, message, context, details, false)
end

--- Backward compatibility and default logging method
--- Defaults to INFO level
function ZUL.log(modName, message, context, details)
	_log(ZUL.Level.INFO, modName, message, context, details, true)
end

-- Child Logger Factory (Pino-style)

--- Create a child logger for a specific mod
--- @param modName string
--- @return table
function ZUL.new(modName)
	-- Proactive attempt to bind settings if this is the first logger created
	if not ZUL.sandboxOptions.loaded then
		ZUL.loadSandboxOptions()
	end

	local child = {}

	function child:trace(msg, ctx, det) ZUL.trace(modName, msg, ctx, det) end

	function child:debug(msg, ctx, det) ZUL.debug(modName, msg, ctx, det) end

	function child:info(msg, ctx, det) ZUL.info(modName, msg, ctx, det) end

	function child:warn(msg, ctx, det) ZUL.warn(modName, msg, ctx, det) end

	function child:error(msg, ctx, det) ZUL.error(modName, msg, ctx, det) end

	function child:fatal(msg, ctx, det) ZUL.fatal(modName, msg, ctx, det) end

	function child:log(msg, ctx, det) ZUL.log(modName, msg, ctx, det) end

	function child:setLevel(level) ZUL.setLevel(modName, level) end

	function child:getEffectiveLevel() return ZUL.getEffectiveLevel(modName) end

	return child
end

-- Attempt early load (usually fails during script load, but harmless)
ZUL.loadSandboxOptions()

return ZUL
