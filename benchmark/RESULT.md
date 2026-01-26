# ZUL Benchmark & Stress Test Results

## Test Environment (PC Specifications)

- **OS**: Windows 10, version: 10.0, arch: amd64.
- **Processor**: Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz (Intel64 Family 6 Model 45 Stepping 7).
- **Cores**: 16 (Available: 16).
- **Motherboard**: X79.
- **Memory**:
  - Max: 3072.0 MB.
  - Total available to JVM: 1026.0 MB.
  - Free (at time of test): ~995 MB.
- **Graphics**: NVIDIA GeForce GTX 1050 Ti (4GB VRAM, Driver v32.0.15.7688).
- **DISK**: NVME Samsung SSD 970 EVO Plus 500GB
- **PZ Version**: 42.13.2
- **ZUL Version**: 1.1.0

---

## 1. Quantitative Benchmark (`MyBenchmark.lua`)

The benchmark measures the raw throughput of the logging system by generating 5,000 log lines as quickly as possible.

### Results

- **Total Lines Logged**: 5,000
- **Elapsed Time**: 1.00 seconds
- **Throughput**: **5,000.00 Lines Per Second (LPS)**

> **Observation**: The system successfully processed 5,000 log entries in exactly 1 second, meeting the target guideline of handling high-volume logging without crashing.

---

## 2. In-Game Stress Test (`MyClientStressTest.lua`)

The stress test spams **200 TRACE logs every single game tick** to simulate an extreme "worst-case" scenario for mod debugging.

### Results

- **Load**: 200 logs/tick (approx. 6,000 - 12,000 logs/sec dependent on framerate).
- **Duration**: Auto-stopped after 500 ticks.
- **Performance Impact**:
  - Lowest recorded FPS during stress: **21 FPS**
  - _(Note: Baseline FPS was not explicitly recorded but is assumed to be higher)._

### Conclusion

While the frame rate dropped to 21 FPS under this extreme load (which is expected given the sheer volume of I/O and string formatting), the game remained stable and the test completed successfully without crashing the Lua engine or the JVM. This confirms ZUL's stability even under abuse-level conditions on this hardware configuration.
