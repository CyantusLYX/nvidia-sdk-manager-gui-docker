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
IMAGE=${IMAGE:-localhost/nvidia-sdk-manager-gui:2.3.0-12617}
SDKM_DIR=${SDKM_DIR:-$(pwd)/sdkm_downloads}
mkdir -p "${SDKM_DIR}"

# --- 統一的權限和掛載設定 ---
PRIV_ARGS=(--privileged)
UDEV_MOUNT=("-v" "/run/udev:/run/udev:ro") # 將 UDEV_MOUNT 從字串改為陣列

# Podman/Docker 通用設定
EXTRA_ARGS=()
EXTRA_ENV=()
EXTRA_VOL=()
if [[ "${RUNTIME}" == "podman" ]]; then
    XSOCK_MOUNT="/tmp/.X11-unix:/tmp/.X11-unix:Z"
else
    XSOCK_MOUNT="/tmp/.X11-unix:/tmp/.X11-unix"
fi
XAUTH_HOST=${XAUTHORITY:-$HOME/.Xauthority}
if [[ -f "${XAUTH_HOST}" ]]; then
    EXTRA_ENV+=(-e XAUTHORITY=/home/nvidia/.Xauthority -e QT_X11_NO_MITSHM=1)
    if [[ "${RUNTIME}" == "podman" ]]; then
        EXTRA_VOL+=(-v "${XAUTH_HOST}":/home/nvidia/.Xauthority:Z)
    else
        EXTRA_VOL+=(-v "${XAUTH_HOST}":/home/nvidia/.Xauthority)
    fi
else
    EXTRA_ENV+=(-e QT_X11_NO_MITSHM=1)
fi

echo "🚀 Starting NVIDIA SDK Manager with ${RUNTIME}..."
CMD_PREFIX=""
if [[ "${RUNTIME}" == "podman" && "$(id -u)" -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        echo "💡 For hardware flashing, running podman with sudo is recommended."
        CMD_PREFIX="sudo"
    fi
fi

# --- 執行的指令 ---
${CMD_PREFIX} "${RUNTIME}" run \
    -it --rm \
    --pull=never \
    --net=host \
    --ipc=host \
    "${PRIV_ARGS[@]}" \
    "${UDEV_MOUNT[@]}" \
    -v "${XSOCK_MOUNT}" \
    "${EXTRA_VOL[@]}" \
    -v "${SDKM_DIR}":/home/nvidia/Downloads/nvidia \
    -e DISPLAY=${DISPLAY} \
    -e USER=nvidia -e LOGNAME=nvidia -e HOME=/home/nvidia \
    "${EXTRA_ENV[@]}" \
    "${EXTRA_ARGS[@]}" \
    "${IMAGE}"