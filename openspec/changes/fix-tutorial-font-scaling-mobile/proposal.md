## Why

When launch/tutorial dialogues and destination indicators are presented on mobile screens (especially upon first launch before any dungeon settings are saved), font sizes are too small to read comfortably, and `RichTextLabel` overrides are not properly applied.

## What Changes

- Increase base font sizes in `dialogue_box.tscn` (`TextLabel` body text to 18px, `SpeakerLabel` to 19px, `PromptIndicator` to 13px) and `tutorial_indicator.tscn` (destination label to 14px).
- Expand `BottomContainer` / `Panel` minimum height in `dialogue_box.tscn` to 160px to accommodate larger fonts without vertical clipping.
- Update `_cache_base_font_sizes()` and `_apply_font_scale()` in `dialogue_box.gd` to properly target `RichTextLabel` theme font properties (`normal_font_size` and `bold_font_size`).
- Add mobile viewport auto-scale detection in `dialogue_box.gd` so first-time players on mobile devices immediately get readable dialogue text before visiting any settings page.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
<!-- None (pure UI font scaling bug fix, skip_specs: true) -->

## Impact

- **Affected Code**: `UI/Dialogue/dialogue_box.gd`, `UI/Dialogue/dialogue_box.tscn`, `UI/Dialogue/tutorial_indicator.tscn`.
- **Behavior**: Ensures tutorial dialogue text and floating destination indicators are auto-scaled and clear on mobile devices from first boot.
