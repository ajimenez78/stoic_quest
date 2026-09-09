## Purpose

Proporciona un menú de configuración accesible mediante un icono en pantalla para controlar preferencias del usuario como la música de fondo de forma legible y optimizada para dispositivos móviles.

## Requirements

### Requirement: Floating Settings Icon

El sistema DEBE (MUST) mostrar un botón de acceso a la configuración en la esquina superior derecha de la pantalla dentro de una capa superior (`CanvasLayer`).

#### Scenario: Settings button visibility and access
- **WHEN** el usuario navega por cualquier pantalla o mapa principal del juego
- **THEN** el icono de configuración se muestra de forma persistente en la esquina superior derecha con un área táctil mínima de 48x48 píxeles

#### Scenario: Opening settings menu from icon
- **WHEN** el usuario toca el icono de configuración
- **THEN** el menú superpuesto de configuración se abre inmediatamente sin pausar la ejecución del juego

### Requirement: Settings Overlay Menu

El sistema DEBE (MUST) presentar un menú modal superpuesto con fondo semitransparente que permita cerrar la interfaz mediante un botón de cierre o tocando fuera del panel.

#### Scenario: Closing settings menu via close button
- **WHEN** el usuario presiona el botón de cierre (X) del menú de configuración
- **THEN** el panel superpuesto se oculta y el usuario retorna a la pantalla de juego en el mismo estado

### Requirement: Background Music Toggle

El sistema DEBE (MUST) incluir un control de tipo conmutador (`CheckButton` / Switch) para activar y desactivar la música de fondo inmediatamente.

#### Scenario: Turning off background music
- **WHEN** el usuario desactiva la opción de música de fondo en el menú de configuración
- **THEN** la reproducción de la música de fondo se silencia de inmediato

#### Scenario: Turning on background music
- **WHEN** el usuario activa la opción de música de fondo en el menú de configuración
- **THEN** la reproducción de la música de fondo se reanuda o desmutea inmediatamente

### Requirement: Mobile Typography and Touch Targets

El sistema DEBE (MUST) utilizar un tamaño de fuente de al menos 20px para los nombres de las opciones y botones táctiles de al menos 48x48px para asegurar legibilidad y facilidad de uso en pantallas móviles.

#### Scenario: Legibility on mobile viewports
- **WHEN** el menú de configuración se muestra en cualquier dispositivo móvil
- **THEN** los textos de las opciones son claramente legibles sin solaparse y los elementos interactivos responden adecuadamente a pulsaciones táctiles

### Requirement: Setting Preference Persistence

El sistema DEBE (MUST) guardar la preferencia del estado de la música de fondo de forma persistente y aplicarla al iniciar la aplicación o cargar nuevas escenas.

#### Scenario: Restoring music setting on application launch
- **WHEN** la aplicación se inicia o se carga una nueva escena
- **THEN** el sistema consulta la preferencia guardada en el almacenamiento local y aplica el estado de música de fondo (activado o desactivado) correspondiente
