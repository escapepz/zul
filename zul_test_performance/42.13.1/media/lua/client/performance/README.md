# ZUL Performance Examples

This directory contains tools for benchmarking and stress-testing the ZUL logging framework to ensure it meets the performance requirements of your mod.

## Files

- **[MyBenchmark.lua](./MyBenchmark.lua)**: A quantitative benchmark that measures how many log lines ZUL can process per second.
- **[MyClientStressTest.lua](./MyClientStressTest.lua)**: A stress test designed to be run in-game to observe the impact of heavy logging on FPS and game stability.

## How to Test

### Running the Benchmark

The benchmark script generates 5,000 log entries and calculates the **Lines Per Second (LPS)**.

1. Run the script via the debugger or by including it in your mod.
2. Check the console/log for the final results table.
3. **Guideline**: `DEBUG` logging should typically handle ~1,000 lines/sec without major impact.

### Running the Stress Test

The stress test spams 200 `TRACE` logs every single game tick.

1. Load the script in a single-player or local server environment.
2. Monitor your FPS. The drop should be linear and predictable.
3. Use `ZUL_StopStress()` in the Lua console to stop the test.

## Key Observations

- **FPS Stability**: Ensure there are no significant "hitches" or freezes during heavy logging.
- **Disk I/O**: Watch for log file growth and ensure the OS handles the write pressure gracefully.
- **GC Pressure**: Frequent logging of complex objects can trigger the Java Garbage Collector. Use these tools to find a safe balance.
