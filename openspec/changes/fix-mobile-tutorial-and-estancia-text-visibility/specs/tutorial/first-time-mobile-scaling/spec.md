## Purpose

Ensures onboarding tutorial dialogues and destination indicators automatically scale on mobile devices with legible typography and responsive layout bounds.

## ADDED Requirements

### Requirement: Tutorial dialogue auto-scaling on mobile devices

The tutorial dialogue box SHALL detect mobile and touchscreen environments using device features and viewport constraints, automatically applying a 1.4x scale factor to dialogue text on mobile.

#### Scenario: First-time tutorial displayed on mobile screen
- **WHEN** a user launches the game on a mobile device or touchscreen viewport for the first time
- **THEN** the tutorial dialogue text scales to 1.4x default size with bold font rendering on BBCode tags and a minimum panel height of at least 180px

### Requirement: Floating destination indicator mobile scaling

The floating destination indicator badge SHALL scale its font size and padding when rendered on mobile environments.

#### Scenario: Target building indicator active on mobile
- **WHEN** the tutorial points the user to a target building (Stoa, Gym, Home) on a mobile device
- **THEN** the indicator badge text is rendered in a larger legible font size with sufficient padding
