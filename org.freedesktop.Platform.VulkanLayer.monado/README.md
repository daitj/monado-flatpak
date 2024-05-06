# Monado Layer

In order to launch applications with the Monado runtime, the included Flatpak `org.freedesktop.Platform.VulkanLayer.monado` is required. To install it, build and install the Flatpak like so:

```
flatpak run org.flatpak.Builder --user --install --force-clean monado-ext-build-dir org.freedesktop.Platform.VulkanLayer.monado/org.freedesktop.Platform.VulkanLayer.monado.json
```

However, additional work needs to be done to allow OpenXR applications to connect to the Monado runtime.

## Socket

In order for any clients to access the `monado_comp_ipc` socket, they must have the ability to see the location of the socket on the filesystem. Because of the Flatpak sandbox, access must be granted to Monado's `XDG_RUNTIME_DIR`. Additionally, the socket must be symlinked to `$XDG_RUNTIME_DIR/monado_comp_ipc`. This can be done for individual Flatpaks like so:

```
flatpak --user override --filesystem=xdg-run/.flatpak/org.monado.Monado <flatpak-id>
flatpak run --command=ln <flatpak-id> -s $XDG_RUNTIME_DIR/.flatpak/org.monado.Monado/xdg-run/monado_comp_ipc $XDG_RUNTIME_DIR/
```

where `<flatpak-id>` is the qualified name of the app (i.e. Steam is `com.valvesoftware.Steam`). While the override can be applied globally, it is not recommended for security reasons.

### Host Access

To run host applications with the Monado Flatpak, a symlink from `$XDG_RUNTIME_DIR/.flatpak/org.monado.Monado/xdg-run/monado_comp_ipc` needs to be made to `$XDG_RUNTIME_DIR`. To make a permanent symlink, follow the below instructions:

```
mkdir -p $HOME/.config/user-tmpfiles.d
echo 'L %t/monado_comp_ipc - - - - .flatpak/org.monado.Monado/xdg-run/monado_comp_ipc' > $HOME/.config/user-tmpfiles.d/monado-ipc.conf
systemctl --user enable --now systemd-tmpfiles-setup.service
```

This does require a valid `libopenxr_monado.so` and `openxr_monado.json` or `active_runtime.json` on the host however, which can be obtained by copying the necessary files to their own locations.

## Using Monado

`XR_RUNTIME_JSON` must also be exported and set to `/usr/lib/extensions/vulkan/monado/share/openxr/1/openxr_monado.json` prior to running the OpenXR client. This can be done *inside* of the client Flatpak like so:

```
XR_RUNTIME_JSON=/usr/lib/extensions/vulkan/monado/share/openxr/1/openxr_monado.json path_to_binary arg1 arg2 ...
```

Alternatively, if Monado is the only OpenXR runtime, then setting `XR_RUNTIME_JSON` can be avoided by copying `openxr_monado.json` to the `active_runtime.json` located in the Flatpak's configuration directory. This can be done like so, where `<flatpak-id>` is the qualified flatpak name:

```
flatpak run --command=mkdir <flatpak-id> -p $HOME/.config/openxr/1/
flatpak run --command=cp <flatpak-id> /usr/lib/extensions/vulkan/monado/share/openxr/1/openxr_monado.json $HOME/.config/openxr/1/active_runtime.json
```

Alternatively, an environment variable override could also be used to set `XR_RUNTIME_JSON` like so, where `<flatpak-id>` is the qualified flatpak name:

```
flatpak --user override --env=XR_RUNTIME_JSON=/usr/lib/extensions/vulkan/monado/share/openxr/1/openxr_monado.json <flatpak-id>
```

### Wrapper Script

A wrapper script `monado-wrapper` is included to handle both `monado_comp_ipc` and `XR_RUNTIME_JSON`, located at `/usr/lib/extensions/vulkan/monado/bin/monado-wrapper`. Simply append the program and all of its arguments to the end of the script to run it under Monado like so:

```
/usr/lib/extensions/vulkan/monado/bin/monado-wrapper path_to_binary arg1 arg2 ...
```

Some applications may append the `bin` directories under `/usr/lib/extensions/vulkan` to `PATH`. For those applications, it is sufficient to run `monado-wrapper` like so:

```
monado-wrapper path_to_binary arg1 arg2 ...
```

This can only be used from *inside* the Flatpak of the application that requires an OpenXR runtime.