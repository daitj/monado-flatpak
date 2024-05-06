# Monado

The Monado service is included with `org.monado.Monado`. To install this, build and install the Flatpak like so:

```
flatpak run org.flatpak.Builder --user --install --force-clean monado-build-dir org.monado.Monado/org.monado.Monado.json
```

To run the service, simply run the flatpak to run `monado-service`:

```
flatpak run org.monado.Monado
```

Pressing `<enter>` will gracefully end the service.

### Configuration

By default, `org.monado.Monado` runs with the following environment variables set:

```
XRT_COMPOSITOR_COMPUTE=1
XRT_COMPOSITOR_DEFAULT_FRAMERATE=90
```

Using the host terminal, the configuration for Monado can be changed. For example, to set a render resolution of 200% for a new session, run the following:

```
flatpak run --env=XRT_COMPOSITOR_SCALE_PERCENTAGE=200 org.monado.Monado
```

Alternatively, run the below to override the environment variable options for any future sessions:

```
flatpak --user override --env=XRT_COMPOSITOR_SCALE_PERCENTAGE=200 org.monado.Monado
```

### Caveats

- If the service does not end gracefully, the socket may need to be removed prior to starting a new session. This can be done like so:

    ```
    flatpak run --command=rm org.monado.Monado $XDG_RUNTIME_DIR/monado_comp_ipc
    ```

- The systemd service and socket normally available with Monado is not available with the Flatpak due to the inability to export systemd services and sockets from Flatpak applications

- Not all Monado compile-time options and features have been enabled. `modules/monado.json` can be modified to include any new dependencies for new features, but YMMV

- While support for the proprietary SteamVR Lighthouse driver has been included, additional steps are needed to use the driver

    - If Steam is installed on the host, `org.monado.Monado` must be granted access to the Steam directories. This can be done like so:

        ```
        flatpak --user override --filesystem=xdg-data/Steam:ro org.monado.Monado
        flatpak --user override --filesystem=~/.steam:ro org.monado.Monado
        ```

    - If Steam is a Flatpak, a symlink from `$HOME/.var/app/com.valvesoftware/.steam` to Monado`'s home directory is necessary. This can be done like so:
        
        ```
        flatpak --user override --filesystem=~/.var/app/com.valvesoftware.Steam:ro org.monado.Monado
        flatpak run --command=ln org.monado.Monado -s $HOME/.var/app/com.valvesoftware.Steam/.steam $HOME/