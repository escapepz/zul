local hasZUL, ZUL = pcall(require, "ZUL")
local logger = nil

if hasZUL and type(ZUL) == "table" and type(ZUL.new) == "function" then
    local ok, result = pcall(ZUL.new, "ESC_AggressiveFix")
	if ok and result then
		logger = result
		---@diagnostic disable-next-line: need-check-nil
		pcall(function() logger:info("ZUL detected and enabled") end)
		---@diagnostic disable-next-line: need-check-nil
		pcall(function() logger:debug("debug log enabled") end)
	else
		print("[ESC_AggressiveFix] ZUL present but logger creation failed")
	end
else
    print("[ESC_AggressiveFix] ZUL not found, using fallback logging")
end

local function safePrint(msg, debug)
    if logger then
        if debug == true then
			---@diagnostic disable-next-line: need-check-nil
			pcall(function() logger:debug(msg) end)
		else
			---@diagnostic disable-next-line: need-check-nil
			pcall(function() logger:info(msg) end)
		end
	else
		if debug ~= true then
			print("[ESC_AggressiveFix] " .. tostring(msg))
		end
	end
end

return safePrint
