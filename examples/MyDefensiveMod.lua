-- MyDefensiveMod.lua aka safeLogger.lua
local hasZUL, ZUL = pcall(require, "ZUL")
local logger = nil
local LOG_MODULE_NAME = "MyDefensiveMod"

if hasZUL and type(ZUL) == "table" and type(ZUL.new) == "function" then
	local ok, result = pcall(ZUL.new, LOG_MODULE_NAME)
	if ok and result then
		logger = result
		---@diagnostic disable-next-line: need-check-nil
		pcall(function() logger:info("ZUL detected and enabled") end)
	end
end

local function safeLog(msg, debug)
	if logger then
		if debug then
			---@diagnostic disable-next-line: need-check-nil
			pcall(function() logger:debug(msg) end)
		else
			---@diagnostic disable-next-line: need-check-nil
			pcall(function() logger:info(msg) end)
		end
	elseif not debug then
		print("[" .. LOG_MODULE_NAME .. "] " .. tostring(msg))
	end
end

return safeLog
