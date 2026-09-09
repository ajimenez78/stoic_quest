## Context

Véase `proposal.md` para la motivación general del cambio.

Actualmente la aplicación Stoa utiliza escenas en Godot 4 con `playground.tscn` como escena principal y `athens.tscn` cargando el audio de fondo (`AudioStreamPlayer`). La capa de UI global y datos de progreso se gestionan a través de los singletons en `00_Globals` (`progress.gd`, `global_level_manager.gd`).

## Goals / Non-Goals

**Goals:**
- Crear un componente de UI modular en Godot (`UI/Settings/settings_menu.tscn` / `settings_menu.gd`).
- Proveer un icono flotante táctil (engranaje) en la esquina superior derecha (`layer = 100`) para abrir el menú de configuración.
- Implementar un conmutador de música de fondo accesible con texto de tamaño adaptado a móvil (20-24px).
- Guardar y restaurar la preferencia `music_enabled` en `ProgressStore` (`00_Globals/progress.gd`).
- Mantener la ejecución del juego activa cuando el menú está desplegado (no pausa `get_tree().paused`).

**Non-Goals:**
- Ajuste fino de volumen con sliders (solo conmutador ON/OFF de música).
- Configuración de gráficos, idioma o guardado manual en esta fase.

## Decisions

### 1. Estructura de Escena UI con CanvasLayer
- **Decisión**: Crear una escena reutilizable `settings_menu.tscn` que incluye tanto el botón flotante de acceso (`TextureButton` / `Button`) como el panel modal (`Control` + `PanelContainer`).
- **Alternativas consideradas**:
  - *Insertar el icono directamente en cada escena/mapa*: Rechazado por duplicación de código y mantenimiento.
  - *Usar un CanvasLayer a nivel Playground*: Seleccionado por garantizar renderizado constante por encima de mapas y mazmorras.

### 2. Gestión de Silenciamiento de Audio
- **Decisión**: Utilizar `AudioServer.set_bus_mute()` o alternativamente el control de volumen/pausa del reproductor de música según el bus activo de audio en Godot, sincronizado centralizadamente desde `ProgressStore`.
- **Alternativas consideradas**:
  - *Detener/reproducir manualmente cada AudioStreamPlayer*: Propenso a errores al cambiar de escena.
  - *Control mediante bus en AudioServer o helper global en ProgressStore*: Elegido porque aplica inmediatamente a cualquier pista de música de fondo global.

### 3. Persistencia de Preferencias
- **Decisión**: Añadir el campo `music_enabled: bool` (por defecto `true`) a `ProgressStore` (`progress.gd`), que guarda el estado en el archivo de guardado local del usuario y emite una señal `music_setting_changed(enabled)` para que la UI y el reproductor de audio se actualicen.

### 4. Layout Adaptado a Móvil
- **Decisión**:
  - Botón de acceso de mínimo 48x48px en la esquina superior derecha con `Anchors` relativas.
  - Opciones de menú dispuestas verticalmente con `VBoxContainer`, espacios holgados (`separation = 16`), y `LabelSettings` con tamaño de fuente de 22px.
  - Conmutador `CheckButton` amplio para interacción táctil responsiva.

## Risks / Trade-offs

- **[Riesgo]**: La pista de música de fondo en `athens.tscn` tiene `autoplay = true` y podría sonar brevemente antes de que se lea el estado guardado.
  - **Mitigación**: `ProgressStore` aplicará el estado mute en su método `_ready()` o durante la inicialización de la escena antes de que comience el stream de audio.
