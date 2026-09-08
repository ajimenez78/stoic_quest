## Why

In `Apprentice/Scripts/apprentice.gd`, `var input_dir` was declared inside an `else:` branch in `_process()`, but checked on line 86 outside that branch. This caused a GDScript runtime/parse error: `Error en (86, 12): Identifier "input_dir" not declared in the current scope.`

## What Changes

- Declare `var input_dir := Vector2.ZERO` at the outer scope of `_process()` (before the dialogue check) or move the `input_dir` handling inside the `else:` branch.
- Ensure `input_dir` is safely accessible and defaults to `Vector2.ZERO` when dialogue is active.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
<!-- None (pure GDScript scope fix, skip_specs: true) -->

## Impact

- **Affected Code**: `Apprentice/Scripts/apprentice.gd`
- **Behavior**: Resolves GDScript compilation error so Apprentice script runs cleanly without script errors.
