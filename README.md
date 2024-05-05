# Monado Flatpak

# Disclaimer

This has only been tested on my atomic Fedora 40 desktop! I have not attempted to use this with both Nvidia or Intel graphics cards! For any Nvidia or Intel users, YMMV.

# Install

The following Flatpak dependencies must be installed prior to build either of the Flatpaks:

- org.flatpak.Builder
- org.freedesktop.Sdk//23.08
- org.freedesktop.Platform//23.08
- com.valvesoftware.Steam

# Usage

Included are three flatpaks- `org.monado.Monado`, `org.freedesktop.Platform.VulkanLayer.monado`, and `com.valvesoftware.Steam.Utility.monado`.

## org.monado.Monado

### Usage

This is the main Monado service. Running the Flatpak will automatically run `monado-service`. It is recommended to run this via a terminal for now like so:

`flatpak run org.monado.Monado`

Pressing `enter` will end the service. Additional environment variables can be added to activate different features like so:

`flatpak run --env=XRT_COMPOSITOR_COMPUTE=1 --env=XRT_DEBUG_GUI=1 --env=XRT_COMPOSITOR_SCALE_PERCENTAGE=200 org.monado.Monado`

Additionally, the included command line and debug tools for Monado can be run like so:

```
flatpak run --command=monado-cli org.monado.Monado <options>
flatpak run --command=monado-ctl org.monado.Monado <options>
flatpak run --command=monado-gui org.monado.Monado <options>
```

### Install

Build and install this like so:

`flatpak run org.flatpak.Builder --user --install --force-clean monado-build-dir org.monado.Monado.json`

## org.freedesktop.Platform.VulkanLayer.monado

This is the layer that most Flatpaks will have access to in order to work with the Monado service.

### Install

Build and install this like so:

`flatpak run org.flatpak.Builder --user --install --force-clean monado-ext-build-dir org.freedesktop.Platform.VulkanLayer.monado.json`

This is not sufficient however, and additional work must be done in order to interface with Monado.

### Override

In order for any clients to access the `monado_comp_ipc` socket, they must have the ability to see the location of the socket on the filesystem. Because of the Flatpak sandbox, access must be granted to Monado's `XDG_RUNTIME_DIR`. This can be done for individual Flatpaks like so:

`flatpak --user override --filesystem=xdg-run/.flatpak/org.monado.Monado <flatpak-id>`

where `<flatpak-id>` is the qualified name of the app (i.e. Steam is `com.valvesoftware.Steam`). While this can be applied globally by not specifying an application, that is not recommended for security reasons.

### Symlink

Additionally, the socket must be symlinked to the client flatpak's `XDG_RUNTIME_DIR` location. This can be done like so from inside of the flatpak's shell:

`ln -sf $XDG_RUNTIME_DIR/.flatpak/org.monado.Monado/xdg-run/monado_comp_ipc $XDG_RUNTIME_DIR/`

### OpenXR Runtime

`XR_RUNTIME_JSON` must also be exported and set to `/usr/lib/extensions/vulkan/monado/share/openxr/1/openxr_monado.json` prior to running the OpenXR client.

### Wrapper Script

A wrapper script `monado-wrapper` is included to handle both the symlinking and `XR_RUNTIME_JSON`, located at `/usr/lib/extensions/vulkan/monado/bin/monado-wrapper`. Simply append the program and all of its arguments to the end of the script to run it under Monado like so:

`/usr/lib/extensions/vulkan/monado/bin/monado-wrapper some_path_to_binary arg1 arg2 ...`

Some applications may append the `bin` directories under `/usr/lib/extensions/vulkan` to `PATH`. For those applications, it is sufficient to run `monado-wrapper` like so:

`monado-wrapper path_to_binary arg1 arg2 ...`

For Steam games that work with Monado, simply add the following to the launch options of the game:

`monado-wrapper %command%`

## com.valvesoftware.Steam.Utility.monado

This is an optional Steam Flatpak extension that provides the Monado SteamVR driver, as well as its own `monado-wrapper` that works under Proton.

### Install

Build and install this like so:

`flatpak run org.flatpak.Builder --user --install --force-clean steamvr-build-dir com.valvesoftware.Steam.Utility.monado.json`

# Extra

## Steam Flatpak

In order to use the proprietary SteamVR lighthouse driver from the Steam flatpak, a symlink to the Steam flatpak's `~/.steam` must be made in the sandboxed home directory of `org.monado.Monado`. This can be done like so:

`flatpak run --command=ln org.monado.Monado -sf $HOME/.var/app/com.valvesoftware.Steam/.steam $HOME/`

# Limitations

- The main Monado service must be run from the terminal.

- The Monado Flatpak currently lacks the full featureset of Monado. This can be remedied by adding the appropriate dependencies to the Monado module located at `modules/monado.json`. Some may not work however, so YMMV.

- Additionally, the systemd socket functionality to automatically start Monado when an OpenXR client is unavailable with the Flatpak.

- The host's OpenXR applications cannot run with the Monado flatpak. Either use or package the applications as Flatpaks or build Monado from source on the host.