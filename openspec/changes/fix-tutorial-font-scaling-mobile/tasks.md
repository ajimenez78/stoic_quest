## 1. Dialogue Box & Indicator Base Font Sizes

- [x] 1.1 Update `UI/Dialogue/dialogue_box.tscn` base font sizes: `TextLabel` (18px), `SpeakerLabel` (19px), `PromptIndicator` (13px), and set `Panel` custom minimum height to 160px.
- [x] 1.2 Update `UI/Dialogue/tutorial_indicator.tscn` destination label font size to 14px.

## 2. RichTextLabel & Responsive Mobile Font Scaling

- [x] 2.1 Update `UI/Dialogue/dialogue_box.gd` to cache and override `normal_font_size` and `bold_font_size` for `RichTextLabel` controls.
- [x] 2.2 Add automatic mobile viewport scale calculation and `viewport.size_changed` handler in `UI/Dialogue/dialogue_box.gd`.
- [x] 2.3 Verify tutorial dialogue and indicator rendering on mobile/desktop viewports.

