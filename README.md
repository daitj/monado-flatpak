# Monado Flatpak

# Disclaimer

This has only been tested on my atomic Fedora 40 desktop! I have not attempted to use this with either Nvidia or Intel graphics cards due to not owning either. For any Nvidia or Intel users, YMMV.

This is also very much tailored to my system. For your own system, some liberties may need to be taken. This is very much a proof of concept!

The VR hardware this has been tested with is a first generation HTC Vive with Valve Index controllers. No other VR hardware has been tested.

Given some of Flatpak's limitations, this does punch a hole into the sandbox by granting access to the Monado flatpak's `XDG_RUNTIME_DIR`, which *could* be a security risk. The Monado flatpak has also been granted full access to the host and Steam flatpak's `$HOME/.steam` directory, which could also be a security risk.

# Dependencies

The following Flatpak dependencies must be installed prior to build either of the Flatpaks:

- org.flatpak.Builder
- org.freedesktop.Sdk//23.08
- org.freedesktop.Platform//23.08
- com.valvesoftware.Steam (only for `com.valvesoftware.Steam.Utility.monado`)

# Usage

Included are three flatpaks- `org.monado.Monado`, `org.freedesktop.Platform.VulkanLayer.monado`, and `com.valvesoftware.Steam.Utility.monado`.

`org.monado.Monado` handles the main Monado service, running straight from the terminal. This is *not* optional.

`org.freedesktop.Platform.VulkanLayer.monado` is layered into most Flatpaks, allowing for Monado to be used quickly, provided that its wrapper script has been run. This is *not* optional.

`com.valvesoftware.Steam.Utility.monado` provides the SteamVR driver for Monado-supported devices, as well as a wrapper script to use Monado with Proton games. This is only needed for Steam games!

# Setup

Clone and enter this directory like so:

```
git clone --recurse-submodules https://github.com/CharlieQLe/monado-flatpak.git
cd monado-flatpak
```

If the flatpak dependencies have not been satisfied, install them now like so:

```
flatpak install org.flatpak.Builder \
    org.freedesktop.Sdk//23.08 \
    org.freedesktop.Platform//23.08 \
    com.valvesoftware.Steam
```

## org.monado.Monado

### Install

Build and install this like so:

`flatpak run org.flatpak.Builder --user --install --force-clean monado-build-dir org.monado.Monado.json`

### Usage

Running the Flatpak will automatically run `monado-service`. It is recommended to run this via a terminal for now like so:

`flatpak run org.monado.Monado`

Pressing `enter` will end the service. Additional environment variables can be added to activate different features like so:

`flatpak run --env=XRT_COMPOSITOR_COMPUTE=1 --env=XRT_DEBUG_GUI=1 --env=XRT_COMPOSITOR_SCALE_PERCENTAGE=200 org.monado.Monado`

Additionally, the included command line and debug tools for Monado can be run like so:

```
flatpak run --command=monado-cli org.monado.Monado <options>
flatpak run --command=monado-ctl org.monado.Monado <options>
flatpak run --command=monado-gui org.monado.Monado <options>
```

## org.freedesktop.Platform.VulkanLayer.monado

### Install

Build and install this like so:

`flatpak run org.flatpak.Builder --user --install --force-clean monado-ext-build-dir org.freedesktop.Platform.VulkanLayer.monado.json`

This is not sufficient however, and additional work must be done in order to interface with Monado.

### Override

In order for any clients to access the `monado_comp_ipc` socket, they must have the ability to see the location of the socket on the filesystem. Because of the Flatpak sandbox, access must be granted to Monado's `XDG_RUNTIME_DIR`. This can be done for individual Flatpaks like so:

`flatpak --user override --filesystem=xdg-run/.flatpak/org.monado.Monado <flatpak-id>`

where `<flatpak-id>` is the qualified name of the app (i.e. Steam is `com.valvesoftware.Steam`). While this can be applied globally, it is not recommended for security reasons.

### Symlink

Additionally, the socket must be symlinked to the client flatpak's `XDG_RUNTIME_DIR` location. This can be done like so from inside of the flatpak's shell:

`ln -sf $XDG_RUNTIME_DIR/.flatpak/org.monado.Monado/xdg-run/monado_comp_ipc $XDG_RUNTIME_DIR/`

This *might* only be required for first time usage. 

### OpenXR Runtime

`XR_RUNTIME_JSON` must also be exported and set to `/usr/lib/extensions/vulkan/monado/share/openxr/1/openxr_monado.json` prior to running the OpenXR client.

Alternatively, if Monado is the only OpenXR runtime, then setting `XR_RUNTIME_JSON` can be avoided by copying `openxr_monado.json` to the `active_runtime.json` located in the Flatpak's configuration directory. This can be done like so, where `<flatpak-id>` is the qualified flatpak name:

```
flatpak run --command=mkdir <flatpak-id> -p ~/.config/openxr/1/
flatpak run --command=cp <flatpak-id> /usr/lib/extensions/vulkan/monado/share/openxr/1/openxr_monado.json ~/.config/openxr/1/active_runtime.json
```

### Wrapper Script

A wrapper script `monado-wrapper` is included to handle both the symlinking and `XR_RUNTIME_JSON`, located at `/usr/lib/extensions/vulkan/monado/bin/monado-wrapper`. Simply append the program and all of its arguments to the end of the script to run it under Monado like so:

`/usr/lib/extensions/vulkan/monado/bin/monado-wrapper some_path_to_binary arg1 arg2 ...`

Some applications may append the `bin` directories under `/usr/lib/extensions/vulkan` to `PATH`. For those applications, it is sufficient to run `monado-wrapper` like so:

`monado-wrapper path_to_binary arg1 arg2 ...`

For Steam games that work with Monado, simply add the following to the launch options of the game:

`monado-wrapper %command%`

## com.valvesoftware.Steam.Utility.monado

### Install

Build and install this like so:

`flatpak run org.flatpak.Builder --user --install --force-clean steamvr-build-dir com.valvesoftware.Steam.Utility.monado.json`

### Usage

Due to being a Steam extension, this extension's `bin` directory is located on the `PATH`, which means the wrapper can be ran as `monado-wrapper`. For every game Monado should be used in, set the launch options like so, while keeping any desired launch options:

`monado-wrapper %command%`

[OpenComposite](https://gitlab.com/znixian/OpenOVR) may be necessary for some games to run. Additionally, Proton currently has an [issue](https://github.com/ValveSoftware/Proton/issues/7382) where OpenXR games cannot use custom OpenXR runtimes, which unfortunately includes Monado.

# Extra

## Steam Flatpak

In order to use the proprietary SteamVR lighthouse driver from the Steam flatpak, a symlink to the Steam flatpak's `~/.steam` must be made in the sandboxed home directory of `org.monado.Monado`. This can be done like so:

`flatpak run --command=ln org.monado.Monado -sf $HOME/.var/app/com.valvesoftware.Steam/.steam $HOME/`

# Limitations

- The Monado Flatpak currently lacks the full featureset of Monado. This can be remedied by adding the appropriate dependencies to the Monado module located at `modules/monado.json` and setting any CMake compiler options. Some may not work however, so YMMV

- Any systemd functionality does not work due to the inability to export systemd services and sockets from Flatpaks

- The host's OpenXR applications cannot run with the Monado flatpak. Either use or package the applications as Flatpaks or build Monado from source on the host
    - AppImages *may* work by extracting their contents and running the extracted binary within a Flatpak, provided that `XR_RUNTIME_JSON` is set properly