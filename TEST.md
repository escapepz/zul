# ZUL Framework: Integration Test Protocol

This document describes the validation flow for verifying ZUL's sandbox integration and filtering logic.

## Objective

Verify that ZUL correctly adopts global log levels for **Included** mods while respecting **Exclusion** vetos and maintaining defaults for **Untracked** mods.

## Phase 1: Configuration

Before starting the server, configure the following **Sandbox Options**:

1.  **Global Log Level**: Set to `DEBUG`.
2.  **Include Mods**: `ZUL_Client`
3.  **Exclude Mods**: `ZUL_Shared`
    - _Note: `ZUL_Server` is intentionally left out of both lists._

## Phase 2: Execution

1.  Apply the sandbox settings.
2.  Restart the Project Zomboid Server.
3.  Connect with a client (to trigger `ZUL_Client` and `ZUL_Shared` client-side hooks).

## Phase 3: Verification

Check the `.tmp/` directory for the following log files and behaviors:

| Mod Name         | File             | Expected Behavior | Key Verification                              |
| :--------------- | :--------------- | :---------------- | :-------------------------------------------- |
| **`ZUL_Client`** | `ZUL_Client.txt` | **ADOPTS DEBUG**  | Sees `[DEBUG]` messages. `isIncluded: true`   |
| **`ZUL_Shared`** | `ZUL_Shared.txt` | **STAYS INFO**    | `[DEBUG]` is **MISSING**. `isIncluded: false` |
| **`ZUL_Server`** | `ZUL_Server.txt` | **STAYS INFO**    | `[DEBUG]` is **MISSING**.                     |

### 1. ZUL_Client.txt (Inclusion Test)

- **Expectation**: Adopts the `DEBUG` level.
- **Evidence**: Look for `[DEBUG] Client logic debug`.
- **Metadata**: `isIncluded` should be `true`, `effectiveLevel` should be `20`.

### 2. ZUL_Shared.txt (Exclusion Test)

- **Expectation**: Remains at `INFO` (Framework Default).
- **Evidence**: The "DEBUG" and "TRACE" messages must be **MISSING**. Only `[INFO]` and above should appear.
- **Metadata**: `isIncluded` will be `false` (vetoed by exclude list).

### 3. ZUL_Server.txt (Untracked Test)

- **Expectation**: Remains at `INFO`.
- **Evidence**: The "DEBUG" and "TRACE" messages must be **MISSING**.
- **Reasoning**: Since an `IncludeMods` list exists and `ZUL_Server` is not on it, it is ignored by the global override.

## Phase 4: Troubleshooting

If `ZUL_Client` does not show `DEBUG` logs:

1.  Verify spelling of the mod name in `IncludeMods` (must exactly match the string passed to `ZUL.new()`).
2.  Check `ARCHITECT_ZUL.md` to ensure the logic hierarchy is understood.
3.  Check the `console.txt` for `[ZUL] [INFO] ZUL Framework initialized with sandbox settings` to confirm settings were actually read.
