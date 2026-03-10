-- MyBenchmark.lua
-- Goal: Measure how much log data ZUL produces per second and identify safe upper bounds.

local hasZUL, ZUL = pcall(require, "zul")
---@diagnostic disable-next-line: impossible-if, unnecessary-if
if not hasZUL or type(ZUL) ~= "table" or not ZUL.new or not ZUL.Level then
    print("ZUL not found or invalid! Skipping benchmark.")
    return
end

local logger = nil
local startTime = nil
local lines = 0
local BENCH_LIMIT = 5000

-- cache newrandom
local myRandom = newrandom()

local function GetIRLTimestamp()
    return math.floor(os.time())
end

local function benchTick()
    if not logger then
        return
    end
    if not startTime then
        startTime = GetIRLTimestamp()
        print("ZUL Benchmark: Started")
    end

    for i = 1, 100 do
        logger:debug("Bench", {
            index = i,
            value = myRandom:random(),
        })
        lines = lines + 1
    end

    if lines >= BENCH_LIMIT then
        local endTime = GetIRLTimestamp()
        local seconds = (endTime - startTime) * 1.0
        -- Fallback to a small value if the benchmark finished in less than 1 second (os.time resolution)
        if seconds <= 0 then
            seconds = 0.001
        end
        local lps = lines / seconds

        logger:info("BenchmarkResult", {
            lines = lines,
            seconds = seconds,
            linesPerSecond = lps,
        })

        -- Note: print() is used intentionally here to provide immediate feedback in the console.
        -- This is part of the benchmark tool reporting and not standard mod logic.
        print("------------------------------------------")
        print(string.format("ZUL Benchmark Results:"))
        print(string.format("Total Lines: %d", lines))
        print(string.format("Elapsed Time: %.2f seconds", seconds))
        print(string.format("Lines Per Second: %.2f", lps))
        print("------------------------------------------")

        ---@diagnostic disable-next-line: impossible-if, unnecessary-if
        if Events and type(Events) == "table" and Events.OnTick then
            Events.OnTick.Remove(benchTick)
        end
        print("ZUL Benchmark: Finished")
    end
end

ZUL_StartBenchmark = function()
    ---@diagnostic disable-next-line: impossible-if, unnecessary-if
    if not hasZUL then
        return
    end
    logger = ZUL.new("ZUL_Bench")
    logger:setLevel(ZUL.Level.DEBUG)
    lines = 0
    startTime = nil

    ---@diagnostic disable-next-line: impossible-if, unnecessary-if
    if Events and type(Events) == "table" and Events.OnTick then
        Events.OnTick.Add(benchTick)
    else
        print("ZUL Benchmark: Events.OnTick not available (running sync loop)")
        for i = 1, 50 do
            benchTick()
        end
    end
end
