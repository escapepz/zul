-- media/lua/client/performance/PerformanceMenu.lua
-- Goal: Provide context menu options to trigger ZUL performance tests and monitor FPS.

local function doStartBenchmark()
    ---@diagnostic disable-next-line: unnecessary-if
    if ZUL_StartBenchmark then
        ZUL_StartBenchmark()
    else
        print("ZUL_StartBenchmark function not found!")
    end
end

local function doStartStress()
    ---@diagnostic disable-next-line: unnecessary-if
    if ZUL_StartStress then
        ZUL_StartStress()
    else
        print("ZUL_StartStress function not found!")
    end
end

---@param player number
---@param context any
---@param worldobjects table
---@param test boolean
local function onFillWorldObjectContextMenu(player, context, worldobjects, test)
    if test then
        return
    end
    ---@type any
    local ctx = context
    local option = ctx:addOption("ZUL Performance Tests")
    local subMenu = ctx:getNew(ctx)
    ctx:addSubMenu(option, subMenu)

    subMenu:addOption("Run quantitative benchmark (5,000 logs)", nil, doStartBenchmark)
    subMenu:addOption("Start heavy stress test (200 TRACE/tick)", nil, doStartStress)
end

---@diagnostic disable-next-line: param-type-mismatch
Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
