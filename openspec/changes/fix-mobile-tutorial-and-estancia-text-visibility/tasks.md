## 1. Tutorial Dialogue and Mobile Auto-Scaling

- [x] 1.1 Update `UI/Dialogue/dialogue_box.gd` mobile detection logic to use `OS.has_feature("mobile")` or `DisplayServer.is_touchscreen_available()`, setting mobile scale factor to `1.4x`
- [x] 1.2 Update `UI/Dialogue/dialogue_box.tscn` to set `theme_override_fonts/bold_font` on `TextLabel` and increase bottom panel minimum height to 180px
- [x] 1.3 Update `UI/Dialogue/tutorial_indicator.gd` and `tutorial_indicator.tscn` to scale font size on mobile screens

## 2. Estancia Text Scaling and Contrast Fixes

- [x] 2.1 Update `Dungeons/Scripts/stoa.gd` to execute `_apply_font_scale()` in `_ready()` on initial room entry
- [x] 2.2 Update `Dungeons/Scripts/home.gd` to cache `RichTextLabel` font properties (`normal_font_size`, `bold_font_size`) and execute `_apply_font_scale()` in `_ready()`
- [x] 2.3 Set explicit dark charcoal `theme_override_colors/default_color` (`Color(0.1, 0.1, 0.1, 1)`) on all `RichTextLabel` controls in `Dungeons/stoa.tscn`, `Dungeons/home.tscn`, and `Dungeons/gym.tscn`

## 3. Verification

- [x] 3.1 Verify via Godot static analysis/script loading that all updated scripts compile cleanly without errors
- [x] 3.2 Verify that tutorial dialogue text, indicators, and estancia labels render correctly scaled and legible on mobile viewport configurations
