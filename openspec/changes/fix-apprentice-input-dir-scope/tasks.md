## 1. Apprentice Input Scope Fix

- [x] 1.1 Move `var input_dir` declaration in `Apprentice/Scripts/apprentice.gd` to the outer scope of `_process()` prior to `is_dialogue` check.
- [x] 1.2 Verify `apprentice.gd` compiles without GDScript parse/scope errors and movement behaves correctly during dialogue and free roam.

