## Why

First-time users on mobile devices currently see onboarding tutorial text and destination indicators rendered too small because `dialogue_box.gd` failed to detect mobile viewports under Godot 4 stretched viewport mode. Additionally, upon entering rooms/estancias (La Stoa, El Gimnasio, El Hogar), text is either unscaled or unreadable/invisible due to unapplied initial font scaling and missing default dark color overrides on RichTextLabel controls over light glass panels.

## What Changes

- **Mobile Viewport Detection & Auto-Scaling in Tutorial**: Update `dialogue_box.gd` to detect mobile/touchscreen environments using `OS.has_feature("mobile")`, `DisplayServer.is_touchscreen_available()`, or narrow viewports, defaulting to a `1.4x` font scale factor on mobile.
- **Tutorial Dialogue Layout & Bold Font**: Set `bold_font` on `TextLabel` in `dialogue_box.tscn` to support BBCode bolding (`[b]...[/b]`), and increase the bottom dialogue panel minimum height to prevent overflow with 1.4x text.
- **Tutorial Indicator Mobile Scaling**: Scale font size and padding of floating destination badges (`tutorial_indicator`) on mobile screens.
- **Initial Font Scale Application in Estancias**: Ensure `_apply_font_scale()` is executed during `_ready()` in `stoa.gd` and `home.gd` so initial font scaling is applied immediately upon entering the room.
- **RichTextLabel Caching & Dark Color Contrast**: Update `home.gd` font caching to properly handle `RichTextLabel` font size overrides (`normal_font_size`, `bold_font_size`), and set `theme_override_colors/default_color` to dark charcoal on all `RichTextLabel` controls across estancias to guarantee text contrast over light glass backgrounds.

## Capabilities

### New Capabilities

- `tutorial/first-time-mobile-scaling`: Onboarding tutorial dialogues and destination indicators auto-scale on mobile devices with proper typography and layout padding.
- `dungeons/estancia-text-legibility-and-scaling`: All room/estancia text (Stoa, Gym, Home) is automatically scaled upon entry and rendered in high-contrast dark typography over light panel backgrounds.

### Modified Capabilities

*None.*

## Impact

- `UI/Dialogue/dialogue_box.gd`, `UI/Dialogue/dialogue_box.tscn`
- `UI/Dialogue/tutorial_indicator.gd`, `UI/Dialogue/tutorial_indicator.tscn`
- `Dungeons/Scripts/stoa.gd`, `Dungeons/stoa.tscn`
- `Dungeons/Scripts/home.gd`, `Dungeons/home.tscn`
- `Dungeons/Scripts/gym.gd`, `Dungeons/gym.tscn`
