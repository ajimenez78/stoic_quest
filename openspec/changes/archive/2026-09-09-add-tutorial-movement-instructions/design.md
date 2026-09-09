## Context

El tutorial guiado (`UI/Dialogue/tutorial_guide.gd`) coordina la introducción del juego a través de diálogos (`DialogueBox`) e indicadores (`TutorialIndicator`).
Actualmente, `DIALOGUES["intro"]` contiene texto estático. El jugador cuenta con `NavigationAgent2D` en `apprentice.gd` y controles táctiles/joystick en `touch_controls`.

## Goals / Non-Goals

**Goals:**
- Inyectar dinámicamente un mensaje adaptativo de movimiento en el diálogo inicial de Zenón según si el dispositivo soporta pantalla táctil/móvil o PC.
- Implementar un indicador visual dinámico en ruta (`path_indicator`) usando `NavigationServer2D.map_get_path()` para posicionarlo en el primer punto de paso del camino visible en el viewport.

**Non-Goals:**
- Modificar el sistema de físicas o movimiento de `Apprentice`.
- Modificar el comportamiento de la navegación en estancias/dungeons donde el tutorial no está activo.

## Decisions

### 1. Inyección de diálogo adaptativo en `tutorial_guide.gd`
- **Decisión**: En lugar de definir una clave estática en `DIALOGUES["intro"]`, construir la lista de líneas de diálogo en tiempo de ejecución combinando la detección de entrada mediante `OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()`.
- **Texto Táctil**: *"Para moverte por Atenas, puedes [b]tocar cualquier punto del terreno[/b] para caminar automáticamente hacia allí ('tap-to-move') o utilizar el [b]joystick virtual[/b] en la pantalla."*
- **Texto PC**: *"Para moverte por Atenas, puedes [b]hacer clic en el terreno[/b] ('click-to-move'), usar el [b]teclado[/b] (WASD / Flechas), el [b]joystick virtual[/b] con el ratón o un [b]mando[/b]."*

### 2. Marcador visual de punto de paso (Waypoint) en el viewport
- **Decisión**: Crear un segundo `TutorialIndicator` (o modo `path` en `TutorialIndicator`) gestionado por `tutorial_guide.gd`.
- **Cálculo de posición**: En `_process` (o `_physics_process`) durante un paso activo del tutorial fuera de estancias:
  1. Obtener la posición global del aprendiz y del nodo objetivo.
  2. Obtener el mapa de navegación `get_world_2d().get_navigation_map()` y calcular la ruta con `NavigationServer2D.map_get_path()`.
  3. Buscar el primer punto de la ruta que esté a más de 40px del aprendiz y dentro del rect visible de la cámara (`get_viewport().get_visible_rect()`).
  4. Posicionar el indicador de camino en ese punto con el texto `"✦ Por aquí ✦"`.

## Risks / Trade-offs

- **[Riesgo]**: `NavigationServer2D.map_get_path()` puede devolver un arreglo vacío en el primer frame si el mapa de navegación aún no se ha sincronizado.
  - **Mitigación**: Verificar que el arreglo de la ruta no esté vacío antes de actualizar la posición del marcador; ocultar el marcador si la ruta aún no está lista.
