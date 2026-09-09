## 1. Persistencia y Lógica de Configuración de Audio

- [x] 1.1 Extender `ProgressStore` (`00_Globals/progress.gd`) para incluir la preferencia `music_enabled`, guardarla/cargarla en disco y emitir la señal de cambio de estado. Verificado al comprobar que la función de guardado/carga no genera errores.
- [x] 1.2 Implementar el helper para aplicar el estado de audio (silenciar/desactivar audio de fondo) automáticamente según la preferencia `music_enabled`. Verificado mediante logs/consola al iniciar la escena.

## 2. Componente de Interfaz de Usuario (Settings Menu)

- [x] 2.1 Crear la escena y script `UI/Settings/settings_menu.tscn` y `settings_menu.gd` con una estructura de `CanvasLayer` (`layer = 100`). Verificado mediante la creación correcta de los archivos de escena.
- [x] 2.2 Diseñar el botón flotante de acceso en la esquina superior derecha con dimensiones mínimas de 48x48px. Verificado al inspeccionar el nodo en el árbol de escenas.
- [x] 2.3 Crear el modal/panel superpuesto con el botón de cierre (X), etiqueta "Música de fondo" con tamaño de fuente ~22px y conmutador `CheckButton` táctil. Verificado mediante la disposición visual y legibilidad en el editor/viewport.
- [x] 2.4 Conectar las señales del conmutador de música y el botón de cierre con `ProgressStore` para actualizar dinámicamente el estado de la música. Verificado mediante alternancia del conmutador y cambio de estado.

## 3. Integración y Verificación

- [x] 3.1 Instanciar la escena `settings_menu.tscn` dentro de `playground.tscn` para asegurar disponibilidad global sobre el mapa y mazmorras. Verificado al abrir `playground.tscn` y verificar la existencia del nodo.
- [x] 3.2 Verificar que al pulsar el icono de configuración se abre/cierra el panel sin pausar el juego y que la música de fondo se apaga/enciende correctamente al alternar el conmutador.
