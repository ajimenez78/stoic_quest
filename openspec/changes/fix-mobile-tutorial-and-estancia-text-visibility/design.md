## Context

Godot 4 runs the 2D display under a fixed viewport stretch size (`1280x720`). On mobile devices, window bounds scale up while internal viewport coordinates remain at 1280x720, causing `get_viewport().get_visible_rect().size.x < 768.0` checks to evaluate as false.

In addition, estancia UI scripts (`stoa.gd` and `home.gd`) cached base font sizes in `_ready()` but did not run `_apply_font_scale()` on startup or handle `RichTextLabel` font size overrides in `home.gd`. Finally, `RichTextLabel` controls missing explicit `theme_override_colors/default_color` properties rendered text with default white color, causing text over white/glass panels to be unreadable or invisible.

See `proposal.md` for overall motivation.

## Goals / Non-Goals

**Goals:**
- Reliable mobile detection in `dialogue_box.gd` using `OS.has_feature("mobile")`, `DisplayServer.is_touchscreen_available()`, and viewport size fallbacks.
- Default mobile font scaling factor of `1.4x` for tutorial dialogue text, matching estancia mobile font scale.
- Correct BBCode bold font binding (`SubResource("FontBold")`) on `TextLabel` in `dialogue_box.tscn`.
- Dynamic panel height adjustment in `dialogue_box.tscn` (min height 180px) to prevent text clipping.
- Immediate font scale execution during `_ready()` in `stoa.gd` and `home.gd`.
- Full `RichTextLabel` font property caching (`normal_font_size`, `bold_font_size`) in `home.gd`.
- Dark charcoal/black `theme_override_colors/default_color` overrides on all estancia `RichTextLabel` controls.

**Non-Goals:**
- Changing dialogue text copy or sequence.
- Refactoring the world map camera or movement mechanics.

## Decisions

### 1. Unified Mobile Detection Pattern
- **Decision**: Standardize mobile detection across `dialogue_box.gd`, `stoa.gd`, `home.gd`, and `gym.gd` using:
  `OS.has_feature("mobile") or DisplayServer.is_touchscreen_available() or get_viewport_rect().size.x < 600`
- **Rationale**: Relying on viewport width alone fails when `stretch_mode="viewport"` maps physical phone displays to a 1280px coordinate space. Checking OS feature flags and touchscreen capability provides precise mobile detection.
- **Alternatives Considered**: Checking physical screen DPI via `DisplayServer.screen_get_dpi()`. Discarded due to inconsistent platform implementation across desktop emulators and Android devices.

### 2. Immediate Scale Execution on Room Entry
- **Decision**: Invoke `_apply_font_scale()` inside `_ready()` in `stoa.gd` and `home.gd` (and `gym.gd` via deferred call).
- **Rationale**: Ensures initial render on mobile immediately displays scaled text without requiring user interaction with font size buttons.

### 3. Explicit Dark Default Font Color Overrides
- **Decision**: Set `theme_override_colors/default_color` to `Color(0.1, 0.1, 0.1, 1)` on all estancia `RichTextLabel` nodes in `.tscn` files.
- **Rationale**: Guarantees high-contrast dark text over semi-transparent light glass panels (`StyleBoxFlat_glass` bg_color = `Color(1, 1, 1, 0.78)`), preventing unstyled text from defaulting to white in Godot 4.

## Risks / Trade-offs

- **[Risk]**: 1.4x text scale in dialogue box might overflow on very narrow 16:9 phones.
  - **Mitigation**: Set `BottomContainer` panel minimum height to 180px and enable scroll / autowrap on labels if needed.
