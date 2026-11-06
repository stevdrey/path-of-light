# Path of Light

A 2D platformer in development with Godot. Explore two levels, collect diamonds and keys, avoid hazards, and find a secret chamber. The game design document is in [GDD.md](GDD.md), and more project details are available in [src/README.md](src/README.md).

## Requirements

- Godot **4.8 beta 2**: the version used to test importing the project. The `project.godot` file specifies Godot 4.8 and the Compatibility renderer; other versions have not been verified for this configuration.
- Git, to clone the repository.

## Open and run

1. Clone the repository:

   ```bash
   git clone git@github.com:stevdrey/path-of-light.git
   ```

2. Open Godot and select **Import** in the Project Manager. Select the `project.godot` file in the cloned folder and open the project.
3. Wait for the editor to finish importing the assets.
4. Press **F5** or click **Run Project**. The main menu will open.

During the first import, music loading errors may appear before the files are ready. If they persist after importing, close and reopen the project.

The repository includes the `godot_mcp` plugin, which is enabled in the project settings. The `.godot/` cache folder is generated locally.

## Default controls

- **A/D or left/right arrows:** move.
- **Space, W, or up arrow:** jump.
- **W or up arrow:** interact and climb ladders.
- **S or down arrow:** climb down ladders.
- **Esc:** pause; **R:** restart.

Controls and volume can be adjusted from the game menu.

## Import files

By project choice, Git ignores `*.import` files. Godot regenerates them when importing assets, but they also store identifiers and import settings: a fresh copy may use default values and differ from the original configuration. The [Godot documentation recommends versioning these files](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/import_process.html#files-generated). Check the results when changing import settings or working from another copy.

## Licenses and assets

The original game code in `src/**/*.gd` is distributed under the [MIT License](LICENSE). This license does not change the terms for third-party assets or automatically cover images, fonts, or sounds.

- The `addons/godot_mcp` plugin has its own [MIT License](addons/godot_mcp/LICENSE).
- The Fredoka font is distributed under the [SIL Open Font License 1.1](assets/fonts/fredoka/OFL.txt).
- Sound credits and documented licenses are in [assets/sounds/CREDITS.md](assets/sounds/CREDITS.md).
- The provenance and redistribution permissions for some visual assets and generated audio still need to be verified. In particular, the [SFX Engine terms](https://sfxengine.com/terms-of-service) restrict the redistribution of sound effects as standalone files. Their presence in this repository does not imply an open license to reuse them; the applicable terms must be reviewed or the files replaced before distributing them in that form.

Therefore, it has not yet been verified that **all game assets** can be redistributed and modified as open content. The code and assets have different license scopes.
