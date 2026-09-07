#!/usr/bin/env bash
set -eou pipefail

proxy="$XDG_RUNTIME_DIR/chrome-bus"

xdg-dbus-proxy "$DBUS_SESSION_BUS_ADDRESS" "$proxy" \
  --filter \
  --talk=org.freedesktop.portal.Desktop \
  --talk=org.freedesktop.secrets \
  --talk=org.freedesktop.Notifications &
proxy_pid=$!
cleanup() {
  kill "$proxy_pid" 2>/dev/null || true
  wait "$proxy_pid" 2>/dev/null || true
  rm -f "$proxy"
}
trap cleanup EXIT

while [[ ! -S "$proxy" ]]; do
  if ! kill -0 "$proxy_pid" 2>/dev/null; then
    wait "$proxy_pid"
    exit 1
  fi
  sleep 0.01
done

bwrap --die-with-parent --new-session --unshare-all --share-net \
  --symlink usr/bin /bin \
  --symlink usr/lib /lib \
  --symlink usr/lib /lib64 \
  --ro-bind /usr /usr \
  --proc /proc --dev /dev \
  --dir /etc \
  --ro-bind /etc/resolv.conf /etc/resolv.conf \
  --ro-bind /etc/hosts /etc/hosts \
  --ro-bind /etc/fonts /etc/fonts \
  --ro-bind-try /var/cache/fontconfig /var/cache/fontconfig \
  --ro-bind-try "$HOME/.local/share/fonts" "$HOME/.local/share/fonts" \
  --ro-bind-try "$HOME/.config/fontconfig" "$HOME/.config/fontconfig" \
  --dir "$HOME/.cache/fontconfig" \
  --ro-bind /opt/google/chrome /opt/google/chrome \
  --bind "$HOME/.config/google-chrome" "$HOME/.config/google-chrome" \
  --bind "$HOME/.cache/google-chrome" "$HOME/.cache/google-chrome" \
  --bind "$HOME/Downloads" "$HOME/Downloads" \
  --tmpfs /tmp \
  --ro-bind "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" \
  --ro-bind "$proxy" "$XDG_RUNTIME_DIR/bus" \
  --ro-bind "$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pipewire-0" \
  --dev-bind-try /dev/dri /dev/dri --dev-bind-try /dev/video0 /dev/video0 \
  google-chrome-stable
