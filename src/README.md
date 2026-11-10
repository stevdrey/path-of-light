# Sendero de descubrimiento

Ejecuta el proyecto con F5. El primer nivel comienza con una zona segura para aprender a moverse y recoger diamantes. El primer obstáculo invita a saltar; más adelante, las plataformas forman una ruta opcional con diamantes amarillos y naranjas de mayor valor. Hay precipicios, enemigos y una cámara secreta con recompensas. Pares de anillos azules señalan el camino hacia un portal; este brilla al acercarte. Pulsa arriba junto a él para entrar y usa el portal de la cámara para regresar.

Use A/D or the arrow keys to move and Space to jump. Collect the blue key and press Up at the door to enter level two; use Up/Down on its ladder to reach the yellow key and open the final door. Hazards and beetles remove hearts; jumping onto beetles defeats them. With assists off, falls cost a heart and return to the last visited safe point while retaining attempt items. Losing all hearts or pressing R restarts the current level with full configured health and its entry inventory; on the final completion screen, R starts again from level one. Session secret/completion records survive retries but are not saved to disk.

Configure three independent assists from **OPCIONES → AYUDAS** or **Esc → AYUDAS**: five hearts instead of three, more frequent authored safe points, and falls without heart loss. Changes apply immediately, persist locally with audio/controls and do not restrict content or rewards. See the [assist evidence](../docs/accessibility-assists-evidence.md) for recovery rules, checks and remaining human evaluation.

Los niveles `scenes/adventure_level_1.tscn` y `scenes/adventure_level_2.tscn` usan TileMapLayer separados para suelo, plataformas y decoración. Los objetos reutilizables están en `collectibles/collectible.tscn`, `scenes/bonus_portal.tscn`, `scenes/level_door.tscn`, `scenes/spikes.tscn`, `scenes/saw.tscn`, `scenes/ladder.tscn`, `scenes/moving_platform.tscn` y `enemies/beetle.tscn`. El TileSet `scenes/ressources/nature_decor_tileset.tres` contiene plantas animadas y rocas decorativas sin colisión.

`character/character.tscn` es reutilizable. `MovementComponent` aplica la física, `AnimationStateMachine` selecciona las poses y las estrategias de control suministran la intención de movimiento. `corner_correction_pixels` ajusta la ayuda para saltar cerca de esquinas.

Los peligros permiten configurar `rotation_speed`, `patrol_axis`, `patrol_distance` y `patrol_speed` en el inspector; una distancia de patrulla cero los deja en su posición. Las plataformas móviles ofrecen `travel_axis`, `travel_distance` y `travel_speed`.

Las cajas reutilizables `collectibles/breakable_crate.tscn` se rompen al saltar contra su parte inferior. En el inspector, `content_kind` selecciona un diamante, llave, corazón o caja vacía; `diamond_points` permite cambiar el valor de los diamantes y `show_key_hint` muestra una pista para las llaves. El efecto de fragmentos está en `collectibles/crate_fragments.tscn`. Los corazones recuperan una vida y permanecen disponibles si la salud ya está completa.

Las capas de física 2D se llaman `Mundo y jugador` (1), `Plataformas escalables` (2) y `Enemigos` (3). La capa 1 es compartida por el terreno y el jugador; las áreas filtran los cuerpos del jugador mediante su grupo. Las máscaras usan estos mismos nombres. Los diamantes generan un destello del color correspondiente al recogerlos.

Los sonidos están en `assets/sounds/sfx/` y su procedencia en `assets/sounds/CREDITS.md`. La música de fondo generada con SFX Engine está en `assets/sounds/music/background_sfx_engine.wav`; `src/audio/scripts/background_music.gd` la reproduce en bucle entre escenas. Los buses `Music` y `SFX` se configuran en el panel Audio de Godot y se guardan en `ressources/default_bus_layout.tres`.
