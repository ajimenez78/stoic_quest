## Context

In `00_Globals/playground.gd`, `_setup_tutorial_guide()` currently loads `res://UI/Dialogue/tutorial_guide.gd` and assigns `Node.new()` to `tutorial_guide` (which is typed as `TutorialGuide`).

## Goals / Non-Goals

**Goals:**
- Instantiate `tutorial_guide` using `TutorialGuide.new()` so that the type matches `TutorialGuide` directly.

**Non-Goals:**
- Modifying `TutorialGuide` signal connections or dialogue logic.

## Decisions

1. **Use `TutorialGuide.new()` directly**
   - *Rationale*: `TutorialGuide` is registered via `class_name TutorialGuide extends Node`. In GDScript 2.0, `TutorialGuide.new()` directly creates a `TutorialGuide` instance, satisfying static typing without runtime errors.

## Risks / Trade-offs

- None identified.
