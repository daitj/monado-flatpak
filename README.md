# Monado Flatpak

# Disclaimer

This has only been tested on my atomic Fedora 40 desktop! I have not attempted to use this with either Nvidia or Intel graphics cards due to not owning either. For any Nvidia or Intel users, YMMV. The VR hardware this has been tested with is a first generation HTC Vive with Valve Index controllers. For any other setups, YMMV. This is also very much tailored to my system. For your own system, YMMV.

Given some of Flatpak's limitations, this does punch a hole into the sandbox as OpenXR applications will require access to the Monado Flatpak's `XDG_RUNTIME_DIR`, which *could* be a security risk. The Monado Flatpak may also require access to Steam, which *could* be a security risk.

# Dependencies

The following Flatpak dependencies must be installed prior to building any of the Flatpaks:

- org.flatpak.Builder
- org.freedesktop.Sdk//23.08
- org.freedesktop.Platform//23.08
- com.valvesoftware.Steam

They can be installed like so:

```
flatpak install org.flatpak.Builder \
    org.freedesktop.Platform//23.08 \
    org.freedesktop.Sdk//23.08 \
    com.valvesoftware.Steam
```

Then clone this repository with its submodules, like so:

```
git clone --recurse-submodules https://github.com/CharlieQLe/monado-flatpak.git
cd monado-flatpak
```

# Included Flatpaks

- [org.monado.Monado](./org.monado.Monado/README.md)
- [org.freedesktop.Platform.VulkanLayer.monado](./org.freedesktop.Platform.VulkanLayer.monado/README.md)
- [com.valvesoftware.Steam.Utility.monado](./com.valvesoftware.Steam.Utility.monado/README.md)