## Context

The tutorial dialogue system consists of:
- `dialogue_box.tscn` / `dialogue_box.gd`: CanvasLayer rendering speaker portrait, name, rich text, and prompt.
- `tutorial_indicator.tscn` / `tutorial_indicator.gd`: Floating label badge over target buildings on the map.

Currently, font size overrides in `dialogue_box.gd` do not scale `RichTextLabel` font properties (`normal_font_size` / `bold_font_size`), and base font sizes (15px for body text, 11px for indicators) are too small on mobile screen resolutions. Moreover, when starting a new game, the player has not visited the Gym settings scene, so no font scale factor has been applied.

## Goals / Non-Goals

**Goals:**
- Enable `dialogue_box.gd` to cache and scale `RichTextLabel` theme font sizes (`normal_font_size`, `bold_font_size`).
- Implement automatic mobile/screen viewport scale calculation in `dialogue_box.gd` on initialization so font scaling works out-of-the-box on mobile devices.
- Increase default font sizes and panel height in `dialogue_box.tscn` and `tutorial_indicator.tscn`.

**Non-Goals:**
- Changing dialogue script content or tutorial logic flow.

## Decisions

1. **RichTextLabel theme font size caching & override**:
   - Cache `{"normal": normal_s, "bold": bold_s}` for `RichTextLabel` controls (using fallback minimums if unset) and apply `add_theme_font_size_override("normal_font_size", ...)` and `add_theme_font_size_override("bold_font_size", ...)`.
   - *Rationale*: Reuses the battle-tested pattern from `gym.gd`.

2. **Automatic viewport scaling in `dialogue_box.gd`**:
   - Check `get_viewport().get_visible_rect().size.x` (or viewport size). If screen width is mobile scale (< 768px), apply a baseline scale factor (e.g. 1.2x) if no scale factor has been set.
   - Connect `get_viewport().size_changed` to recalculate layout and font scale dynamically.

3. **Base Scene Layout & Font Size Adjustment**:
   - `TextLabel`: Set `normal_font_size = 18` in `dialogue_box.tscn`.
   - `SpeakerLabel`: Set `font_size = 19` in `dialogue_box.tscn`.
   - `PromptIndicator`: Set `font_size = 13` in `dialogue_box.tscn`.
   - `Panel`: Set `custom_minimum_size = Vector2(0, 160)` in `dialogue_box.tscn`.
   - `TutorialIndicator`: Set `font_size = 14` in `tutorial_indicator.tscn`.

## Risks / Trade-offs

- [Risk] Larger text in dialogue box on very small screens could overflow if dialogue lines are long → Mitigation: Increased panel height to 160px and `TextLabel` `RichTextLabel` auto-wraps within expanded margins.
