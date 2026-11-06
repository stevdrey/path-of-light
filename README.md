# Path of Light

Un juego de plataformas 2D en desarrollo con Godot. Explora dos niveles, recoge diamantes y llaves, evita peligros y encuentra una cámara secreta. El documento de diseño está en [GDD.md](GDD.md) y hay más detalles del proyecto en [src/README.md](src/README.md).

## Requisitos

- Godot **4.8 beta 2**: es la versión usada en la prueba de importación. El archivo `project.godot` indica Godot 4.8 y el renderizador Compatibility; otras versiones no se han verificado para esta configuración.
- Git, para clonar el repositorio.

## Abrir y ejecutar

1. Clona el repositorio:

   ```bash
   git clone git@github.com:stevdrey/path-of-light.git
   ```

2. Abre Godot y, en el administrador de proyectos, elige **Importar**. Selecciona el archivo `project.godot` de la carpeta clonada y abre el proyecto.
3. Espera a que el editor termine de importar los recursos.
4. Pulsa **F5** o el botón **Ejecutar proyecto**. Se abrirá el menú principal.

En la primera importación pueden aparecer errores de carga de música antes de que los archivos estén listos. Si persisten después de importar, cierra y vuelve a abrir el proyecto.

El repositorio incluye el complemento `godot_mcp`, habilitado en la configuración del proyecto. La carpeta de caché `.godot/` se genera localmente.

## Controles predeterminados

- **A/D o flechas izquierda/derecha:** moverse.
- **Espacio, W o flecha arriba:** saltar.
- **W o flecha arriba:** interactuar y subir escaleras.
- **S o flecha abajo:** bajar escaleras.
- **Esc:** pausar; **R:** reiniciar.

Los controles y volúmenes se pueden ajustar desde el menú del juego.

## Archivos de importación

Por decisión del proyecto, Git ignora los archivos `*.import`. Godot los vuelve a crear al importar los recursos, pero esos archivos también guardan identificadores y ajustes de importación: una copia nueva podría usar valores predeterminados y diferir de la configuración original. La [documentación de Godot recomienda versionarlos](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/import_process.html#files-generated). Revisa el resultado al cambiar opciones de importación o trabajar desde otra copia.

## Licencias y recursos

El código original del juego en `src/**/*.gd` se distribuye bajo la [licencia MIT](LICENSE). Esta licencia no cambia las condiciones de recursos de terceros ni cubre automáticamente las imágenes, fuentes o sonidos.

- El complemento `addons/godot_mcp` tiene su propia [licencia MIT](addons/godot_mcp/LICENSE).
- La fuente Fredoka se distribuye bajo la [SIL Open Font License 1.1](assets/fonts/fredoka/OFL.txt).
- Los créditos y licencias documentados para sonidos se encuentran en [assets/sounds/CREDITS.md](assets/sounds/CREDITS.md).
- La procedencia y los permisos de redistribución de algunos recursos visuales y audios generados todavía deben verificarse. En particular, los [términos de SFX Engine](https://sfxengine.com/terms-of-service) restringen la redistribución de efectos como archivos independientes. Su presencia en este repositorio no implica una licencia abierta para reutilizarlos; hay que revisar los términos aplicables o sustituirlos antes de distribuirlos de esa forma.

Por ello, aún no está verificado que **todos los recursos del juego** puedan redistribuirse y modificarse como contenido abierto. El código y los recursos tienen alcances de licencia distintos.
