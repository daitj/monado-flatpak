# OpenComposite

To run OpenVR games with Monado, OpenComposite has been packaged in the form of `com.valvesoftware.Steam.Utility.opencomposite`. It can be installed like so:

```
flatpak run org.flatpak.Builder --user --install --force-clean opencomposite-build-dir com.valvesoftware.Steam.Utility.opencomposite/com.valvesoftware.Steam.Utility.opencomposite.json
```

## Wrapper Script

A wrapper script `opencomposite-wrapper` has been provided to override the default VR runtime for OpenVR games. Most users should set their games' launch options to the following:

```
opencomposite-wrapper monado-wrapper %command%
```

## Compatibility

Some games such as VRChat are not compatible with the wrapper script. Instead, the `openvrpaths.vrpath` file must be modified to use OpenComposite. This can be used in place of the included wrapper script for most OpenVR titles as well, while also maintaining OpenVR support for whenever SteamVR is used instead of Monado as long as the script isn't used.

### Steam Flatpak

`openvrpaths.vrpath` is located at `$HOME/.var/app/com.valvesoftware.Steam/config/openvr/openvrpaths.vrpath`. Within the file is a section that looks something like this:

```
{
    ...
    "runtime" : 
	[
		"/home/user/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/SteamVR"
	],
    ...
}
```

Replace the path under `runtime` with `/run/parent/app/utils/opencomposite/share/openvr` like so:

```
{
    ...
    "runtime" : 
	[
		"/run/parent/app/utils/opencomposite/share/openvr"
	],
    ...
}
```

However, Steam *may* write to the file and reset the runtime. To avoid this, make a copy of `openvrpaths.vrpath` named `openvrpaths.vrpath.opencomposite` with your changes in the same config directory. Ensure that `openvrpaths.vrpath.opencomposite` is read-only like so:

```
chmod 0444 $HOME/.var/app/com.valvesoftware.Steam/config/openvr/openvrpaths.vrpath.opencomposite
```

Rename the original `openvrpaths.vrpath` to `openvrpaths.vrpath.openvr`. Create a symlink from `openvrpaths.vrpath.openvr` to `openvrpaths.vrpath` like so:

```
flatpak run --command=ln com.valvesoftware.Steam -sf $HOME/.config/openvr/openvrpaths.vrpath.openvr $HOME/.config/openvr/openvrpaths.vrpath
```

Under `$HOME/.var/app/com.valvesoftware.Steam`, create a script called `opencomposite-path-wrapper` with the following contents:

```
#!/bin/bash
ln -sf $HOME/.config/openvr/openvrpaths.vrpath.opencomposite $HOME/.config/openvr/openvrpaths.vrpath
"$@"
ln -sf $HOME/.config/openvr/openvrpaths.vrpath.openvr $HOME/.config/openvr/openvrpaths.vrpath
```

Ensure the script is executable like so:

```
chmod +x $HOME/.var/app/com.valvesoftware.Steam/opencomposite-path-wrapper
```

The Steam game's launch options should now look like this:

```
~/opencomposite-path-wrapper monado-wrapper %command%
```