# Steam

Included with `com.valvesoftware.Steam.Utility.monado` is the Monado SteamVR plugin and a wrapper script for Monado. To build and install this, run the following in your host terminal:

```
flatpak run org.flatpak.Builder --user --install --force-clean steamvr-build-dir com.valvesoftware.Steam.Utility.monado/com.valvesoftware.Steam.Utility.monado.json
```

**Note: `org.freedesktop.Platform.VulkanLayer.monado` is *not* necessary for this to work**

Additionally, more work is necessary to make this work. Like with `org.freedesktop.Platform.VulkanLayer.monado`, permission to access `monado_comp_ipc` is required, as well as symlinking the socket. This can be done like so:

```
flatpak --user override --filesystem=xdg-run/.flatpak/org.monado.Monado com.valvesoftware.Steam
flatpak run --command=ln com.valvesoftware.Steam -s $XDG_RUNTIME_DIR/.flatpak/org.monado.Monado/xdg-run/monado_comp_ipc $XDG_RUNTIME_DIR/
```

## SteamVR Plugin

The Monado SteamVR plugin allows devices using the Monado runtime to run SteamVR. Read [this](https://monado.freedesktop.org/steamvr.html) for more information on the plugin.

To register the driver, run the following in your host terminal:

```
flatpak run --command=$HOME/.local/share/Steam/steamapps/common/SteamVR/bin/vrpathreg.sh com.valvesoftware.Steam adddriver /app/utils/monado/share/steamvr-monado
```

Removing the driver is as simple as running:

```
flatpak run --command=$HOME/.local/share/Steam/steamapps/common/SteamVR/bin/vrpathreg.sh com.valvesoftware.Steam removedriver /app/utils/monado/share/steamvr-monado
```

## Wrapper Script

The SteamVR Monado Flatpak utility provides a `monado-wrapper` that performs all of the same functions as `monado-wrapper` from `org.freedesktop.Platform.VulkanLayer.monado`, but with full Proton support. For Steam games, set the launch options to something like the below:

```
monado-wrapper %command%
```

This *must* be used for every game that requires Proton! [OpenComposite](https://gitlab.com/znixian/OpenOVR) *may* be required for some games.