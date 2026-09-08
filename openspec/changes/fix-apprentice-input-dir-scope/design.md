## Context

In `Apprentice/Scripts/apprentice.gd`, `_process()` evaluates `if !LevelManager.in_dungeon():`. Inside this block, `var input_dir` was declared inside the `else:` branch of `if is_dialogue:`. Outside that branch, line 86 checks `if input_dir.length_squared() > 0.05:`, resulting in an out-of-scope identifier parse error in GDScript.

## Goals / Non-Goals

**Goals:**
- Declare `var input_dir := Vector2.ZERO` at the outer scope of `_process()` (before `if is_dialogue:`) so `input_dir` is always in scope.
- Maintain existing dialogue pause behavior: when `is_dialogue` is true, `input_dir` stays `Vector2.ZERO`, movement target is cleared, and character velocity is reset.

**Non-Goals:**
- Refactoring `Apprentice` state machine or movement physics beyond scope fix.

## Decisions

1. **Declare `input_dir` before `if is_dialogue:`**
   - *Rationale*: Declaring `var input_dir := Vector2.ZERO` above the `if is_dialogue:` conditional ensures `input_dir` is defined in all code paths of `_process()`. When `is_dialogue` is true, `input_dir` remains `Vector2.ZERO`, skipping manual/joystick movement checks smoothly.
   - *Alternatives considered*: Wrapping `if input_dir.length_squared() > 0.05:` inside the `else:` branch. Declaring `var input_dir` at outer scope is cleaner and less prone to nested control flow errors.

## Risks / Trade-offs

- **[Risk] Unintended movement during dialogue** → *Mitigation*: When `is_dialogue` is true, `input_dir` remains `Vector2.ZERO`, ensuring `input_dir.length_squared() > 0.05` evaluates to false.
