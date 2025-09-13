#!/usr/bin/env bash

set -euo pipefail

# Container runtime: prefer podman, fallback to docker
RUNTIME=${RUNTIME:-}
if [[ -z "${RUNTIME}" ]]; then
	if command -v podman >/dev/null 2>&1; then
		RUNTIME=podman
	elif command -v docker >/dev/null 2>&1; then
		RUNTIME=docker
	else
		echo "Error: neither podman nor docker found in PATH" >&2
		exit 1
	fi
fi

# Image can be overridden via env IMAGE
IMAGE=${IMAGE:-nvidia-sdk-manager-gui:2.3.0-12617}

# Common volumes
SDKM_DIR=${SDKM_DIR:-$(pwd)/sdkm_downloads}
mkdir -p "${SDKM_DIR}"

# Podman rootless compatibility tweaks
EXTRA_ARGS=()
if [[ "${RUNTIME}" == "podman" ]]; then
	# Add :Z for SELinux if present (safe even if not enforcing)
	XSOCK="/tmp/.X11-unix"
	if [[ -d "${XSOCK}" ]]; then
		XSOCK_MOUNT="${XSOCK}:${XSOCK}:Z"
	else
		XSOCK_MOUNT="/tmp/.X11-unix:/tmp/.X11-unix:Z"
	fi
	# Rootless podman cannot use --privileged; allow device and udev access
	EXTRA_ARGS+=(--device /dev/bus/usb)
	EXTRA_ARGS+=(--security-opt label=disable)
	NET_ARGS=(--net=host)
	PRIV_ARGS=()
else
	# Docker (may require sudo in some environments)
	NET_ARGS=(--net=host)
	PRIV_ARGS=(--privileged)
	XSOCK_MOUNT="/tmp/.X11-unix:/tmp/.X11-unix"
fi

"${RUNTIME}" run \
	-it --rm \
	"${NET_ARGS[@]}" \
	--ipc=host \
	${PRIV_ARGS:+${PRIV_ARGS[@]}} \
	-v /dev/bus/usb:/dev/bus/usb/ \
	-v "${XSOCK_MOUNT}" \
	-v "${SDKM_DIR}":/home/nvidia/Downloads/nvidia/sdkm_downloads \
	-e DISPLAY=${DISPLAY} \
	"${EXTRA_ARGS[@]}" \
	"${IMAGE}"
