## Purpose

Ensures all text within rooms and estancias (La Stoa, El Gimnasio, El Hogar) is automatically scaled upon entry and rendered with high-contrast dark typography over glass panels.

## ADDED Requirements

### Requirement: Automatic font scale application upon entering estancias

All estancia scenes (Stoa, Home, Gym) SHALL execute font scaling initialization immediately upon entering the room so all static and dynamic text is correctly scaled for the active device.

#### Scenario: User enters an estancia on mobile
- **WHEN** the user enters La Stoa, El Gimnasio, or El Hogar on a mobile screen
- **THEN** all static title labels, body texts, and quote/card labels are rendered in scaled 1.4x font size on initial load

### Requirement: High-contrast dark typography on glass panels

All RichTextLabel controls rendered over light glass background panels SHALL have explicit dark default font colors configured to guarantee text legibility.

#### Scenario: Rendering rich text labels over glass panels
- **WHEN** any RichTextLabel is displayed inside an estancia
- **THEN** the default text color is explicitly set to dark charcoal/black, preventing unstyled or fallback text from appearing white or invisible over light backgrounds
