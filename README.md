![image](https://user-images.githubusercontent.com/5201073/112714947-5d2eb680-8f20-11eb-8af2-4f662b41829f.png)

![image](https://user-images.githubusercontent.com/5201073/112715008-dd551c00-8f20-11eb-874e-d04d4ce3424c.png)


- Easily run NVIDA SDK Manager **GUI** within Docker container (Consisted with Ubuntu 18.04)
- Suitable for users who are using Other linux distros or versions (Ubuntu 20.04 and so on) **or even with Windows**
- Related thread: https://forums.developer.nvidia.com/t/sdk-manager-ubuntu-20-04-lts/125711/24

# Tested Environment
- Ubuntu 20.04 LTS (amd64)
- and so on ... (Contribution on Issue board are welcome!)

# Installation
- Option A: pull a prebuilt image (older tag)
```bash
docker pull jungin500/nvidia-sdk-manager-gui:1.4.1-7402
```
- Option B: build locally (uses sdkmanager 2.3.0-12617)
```bash
podman build -t nvidia-sdk-manager-gui:2.3.0-12617 .
```

# Running (Linux)
- You can use your own directory or docker volume to save SDK Manager download folder (sdkm_downloads)
- You should run below command `start.sh` within Desktop Environment, or `(sdkmanager-gui:7): Gtk-WARNING **: 08:04:31.290: cannot open display: :0` (or similar) error could appear. You can `export DISPLAY=<your_desktop_id>` to workaround this issue.
```bash
./start.sh
```
- The script auto-detects Podman (preferred) or Docker and adjusts flags. You can override:
  - `IMAGE` to select a different tag (default: `nvidia-sdk-manager-gui:2.3.0-12617`)
  - `SDKM_DIR` to change the local downloads directory (default: `./sdkm_downloads`)
- next - **Login with QR Code** and Use SDK Manager! - You can login with QR code on right top corner of login screen. currently, login browser will not appear.

# Running (Windows)
- Can download SDK stuff - but can't connect it with USB directly to Jetson device.  
currently using within Linux is advised.
- **Can** run in WSL1/2 Docker + Xming (https://sourceforge.net/projects/xming/)
```
docker run -it --rm --net=host --privileged --ipc=host -e DISPLAY=<xming_host_address>:0.0 jungin500/nvidia-sdk-manager-gui:1.4.1-7402
```

## Podman notes
- Rootless Podman: the `start.sh` script avoids `--privileged`, adds USB device mapping, and uses `:Z` on X11 volume for SELinux systems.
- If you run manually, an example equivalent command is:
```bash
podman run -it --rm \
	--net=host \
	--ipc=host \
	--device /dev/bus/usb \
	--security-opt label=disable \
	-v /tmp/.X11-unix:/tmp/.X11-unix:Z \
	-v $(pwd)/sdkm_downloads:/home/nvidia/Downloads/nvidia/sdkm_downloads \
	-e DISPLAY=$DISPLAY \
	nvidia-sdk-manager-gui:2.3.0-12617
```

## Ubuntu 20.04 variant
- Build the Ubuntu 20.04-based image:
```bash
podman build -t nvidia-sdk-manager-gui:20.04 -f Dockerfile.20.04 .
```
- Run it via the start script by overriding the image:
```bash
IMAGE=nvidia-sdk-manager-gui:20.04 ./start.sh
```
- Notes:
	- This variant also installs sdkmanager 2.3.0-12617 and includes all GUI/runtime dependencies and locales.
	- You can keep downloads persistent with `SDKM_DIR` (defaults to `./sdkm_downloads`).

# Q&A or Issues
- Write down your issue to "Issue" board! I'll write find out ways to make it work, and respond ASAP. thanks.

# License
- SDK Manager: NVIDIA Corporation. [Link](https://developer.nvidia.com/nvidia-sdk-manager)
- I am not affliated and/or sponsored from NVIDIA. It's my private work to use within Ubuntu 20.04 environment.
