## Why

La aplicación carece de una interfaz centralizada de configuración para ajustar preferencias de usuario. Los usuarios necesitan una forma sencilla y accesible desde la pantalla principal para encender o apagar la música de fondo según su entorno de uso, especialmente en dispositivos móviles.

## What Changes

- **Icono de acceso rápido a configuración**: Añadir un botón táctil flotante con icono de configuración (engranaje) en la esquina superior derecha de la pantalla principal.
- **Panel superpuesto de configuración (Settings Menu)**: Crear una interfaz modal/superpuesta que se despliega al tocar el icono de configuración sin pausar el flujo de juego.
- **Control de Música de Fondo**: Incluir una opción con un interruptor (`CheckButton`/Switch) para apagar y encender la música de fondo.
- **Diseño táctil y legible para móviles**: Configurar tamaños de letra (~20-24px para la opción de menú) y dimensiones mínimas de toque (48x48px) para garantizar excelente visibilidad y usabilidad táctil en pantallas móviles.
- **Persistencia de preferencias**: Almacenar el estado de la música de fondo en `ProgressStore` para mantener la preferencia del usuario entre sesiones de juego.

## Capabilities

### New Capabilities
- `settings-menu`: Interfaz superpuesta de configuración con control de música de fondo, diseño adaptado a móviles y persistencia de estado.

### Modified Capabilities
<!-- No modified capabilities -->

## Impact

- **UI**: Adición de un componente `CanvasLayer` para el icono y el menú de configuración.
- **Audio**: Integración con el reproductor de audio/AudioServer para mutear/desmutear el sonido ambiental.
- **Persistencia**: Extensión de `ProgressStore` (`00_Globals/progress.gd`) para guardar/cargar la preferencia `music_enabled`.
