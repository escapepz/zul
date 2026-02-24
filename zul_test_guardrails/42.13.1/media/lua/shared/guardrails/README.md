# ZUL Guardrails Examples

This directory demonstrates how to extend the ZUL framework with "guardrails" to prevent performance degradation and save file bloat. These guardrails are implemented using **hooks (function wrapping)**, so they do not require modifying the core ZUL library.

## Files

- **[MyZULGuardrails.lua](./MyZULGuardrails.lua)**: The main extension script. It hooks into `ZUL.serialize` to apply safety checks.
- **[GuardrailsTest.lua](./GuardrailsTest.lua)**: A standalone test script to verify that the guardrails are working correctly (filtering keys, truncating tables).

## Features

### 1. Table Truncation

Prevents logging of massive tables that could stall the game or bloat log files. By default, it truncates tables with more than **20 keys**. If a table is truncated, a `_truncated = true` flag is added to the output.

### 2. Sensitive Key Filtering (Deny List)

Automatically removes critical data keys that should never be logged raw, such as:

- `modData`
- `inventory`
- `knownRecipes`

### 3. Level-Aware Serialization

Provides `ZUL.traceHeavy(logger, action, payload)`, which ensures that heavy serialization only occurs if `TRACE` level is actually enabled.

## Usage

To enable these guardrails in your mod, simply require the extension after ZUL has loaded:

```lua
local hasZUL, ZUL = pcall(require, "zul")
if hasZUL then
    require "examples/guardrails/MyZULGuardrails"
end
```
