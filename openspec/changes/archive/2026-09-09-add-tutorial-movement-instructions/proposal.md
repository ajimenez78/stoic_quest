## Why

En la primera ejecución del juego, el diálogo de Zenón orienta al aprendiz hacia La Stoa, pero no explica cómo desplazarse por la polis ni ofrece una orientación visual sobre los primeros pasos del camino. Esta falta de guía dificulta la entrada de nuevos jugadores tanto en dispositivos móviles (táctil/joystick) como en PC (click-to-move/WASD/mando).

## What Changes

- **Instrucciones adaptativas de movimiento en el tutorial**: Inyección de explicación dinámica en el diálogo inicial de Zenón (`intro`) según la plataforma (táctil vs PC). En táctil se explica `tap-to-move` y joystick virtual; en PC se explica `click-to-move`, WASD/flechas, joystick virtual y mando.
- **Indicador de punto de paso en el camino (Waypoint)**: Creación de un marcador flotante dinámico visible en el viewport que señala el siguiente punto de paso en la ruta hacia la estancia objetivo durante el tutorial.

## Capabilities

### New Capabilities
- `tutorial/movement-guidance`: Explicación adaptativa de controles de movimiento e indicación de ruta por puntos de paso visibles en el viewport.

### Modified Capabilities

## Impact

- `UI/Dialogue/tutorial_guide.gd`: Inyección de diálogo adaptativo de controles y actualización del mapa de ruta con `NavigationServer2D`.
- `UI/Dialogue/tutorial_indicator.gd` y `UI/Dialogue/tutorial_indicator.tscn`: Soporte para renderizado adaptativo de punto de paso en ruta (waypoint).
