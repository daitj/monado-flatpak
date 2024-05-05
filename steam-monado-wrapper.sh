#!/bin/sh

# Do nothing if ipc socket is non-existant
if ! [ -e "$XDG_RUNTIME_DIR/.flatpak/org.monado.Monado/xdg-run/monado_comp_ipc" ]; then
    exit 1
fi

# Set the XR_RUNTIME_JSON
export XR_RUNTIME_JSON=/run/parent/usr/lib/extensions/vulkan/monado/share/openxr/1/openxr_monado.json
export PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc

# Symlink the socket
ln -sf $XDG_RUNTIME_DIR/.flatpak/org.monado.Monado/xdg-run/monado_comp_ipc $XDG_RUNTIME_DIR/

# Run the application
"$@"