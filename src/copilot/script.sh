#!/usr/bin/env bash
set -eou pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
sock="$runtime_dir/wrapjail-proxy/proxy.sock"
socat_bin="${WRAPJAIL_SOCAT:-socat}"

gh_pat_token="$(secret-tool lookup service copilot-cli)"

if [[ ! -S "$sock" ]]; then
  printf 'wrapjail: shared proxy is unavailable; start wrapjail-proxy-bridge.service\n' >&2
  exit 1
fi

exec bwrap --die-with-parent --new-session --unshare-all \
  --symlink usr/bin /bin \
  --symlink usr/lib /lib \
  --symlink usr/lib /lib64 \
  --ro-bind /usr /usr \
  --proc /proc --dev /dev \
  --dev-bind-try /dev/net/tun /dev/net/tun \
  --dir /etc \
  --ro-bind /etc/resolv.conf /etc/resolv.conf \
  --ro-bind /etc/hosts /etc/hosts \
  --ro-bind-try /etc/ssl /etc/ssl \
  --ro-bind-try /etc/ca-certificates /etc/ca-certificates \
  --bind "$HOME/.copilot" "$HOME/.copilot" \
  --bind "$HOME/.copilot/session-state" "$HOME/.copilot/session-state" \
  --bind-try "$HOME/projects" "$HOME/projects" \
  --bind-try "$HOME/workspace" "$HOME/workspace" \
  --ro-bind "$sock" /wrapjail/proxy.sock \
  --ro-bind "$socat_bin" /wrapjail/socat \
  --setenv GH_TOKEN "$gh_pat_token" \
  --setenv HTTP_PROXY "http://127.0.0.1:3128" \
  --setenv HTTPS_PROXY "http://127.0.0.1:3128" \
  --setenv http_proxy "http://127.0.0.1:3128" \
  --setenv https_proxy "http://127.0.0.1:3128" \
  sh -c '/wrapjail/socat TCP-LISTEN:3128,bind=127.0.0.1,reuseaddr,fork UNIX-CONNECT:/wrapjail/proxy.sock & exec bash'
