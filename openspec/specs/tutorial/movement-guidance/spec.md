# Tutorial Movement Guidance

## Purpose

Proporciona explicaciones de controles adaptativas y marcadores de ruta en tiempo real para guiar el movimiento del aprendiz durante la peregrinación inicial del tutorial.

## Requirements

### Requirement: Adaptive movement controls explanation in tutorial dialogue

El sistema DEBE inyectar un mensaje explicativo sobre los controles de movimiento en el diálogo inicial de Zenón (`intro`), adaptado a las capacidades del dispositivo.

#### Scenario: First-time tutorial intro on touchscreen devices
- **WHEN** un jugador inicia el tutorial inicial en un dispositivo con pantalla táctil o móvil
- **THEN** el diálogo de Zenón debe incluir una explicación que indique que el aprendiz puede tocar cualquier punto del terreno para desplazarse (`tap-to-move`) o utilizar el joystick virtual en pantalla

#### Scenario: First-time tutorial intro on desktop/PC devices
- **WHEN** un jugador inicia el tutorial inicial en un dispositivo de escritorio/PC
- **THEN** el diálogo de Zenón debe incluir una explicación que indique que el aprendiz puede hacer clic en el terreno, utilizar las teclas de dirección/WASD, el joystick virtual o un mando para desplazarse

### Requirement: Viewport-visible path waypoint indicator

El sistema DEBE mostrar un marcador visual en el camino (`waypoint`) indicando el siguiente punto de paso visible en el viewport hacia la estancia objetivo.

#### Scenario: Target estancia is far or outside viewport
- **WHEN** el aprendiz debe dirigirse a una estancia objetivo durante la fase activa del tutorial
- **THEN** el sistema debe calcular la ruta de navegación y colocar un indicador flotante visible dentro del viewport sobre el primer punto de paso del camino hacia el objetivo

#### Scenario: Apprentice reaches waypoint or enters estancia
- **WHEN** el aprendiz avanza a lo largo del camino o entra a la estancia de destino
- **THEN** el indicador de punto de paso debe actualizarse dinámicamente al siguiente segmento de la ruta o desaparecer al ingresar a la estancia
