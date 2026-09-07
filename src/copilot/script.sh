#!/usr/bin/env bash
set -eou pipefail

gh_pat_token="$(secret-tool lookup service copilot-cli)"

bwrap --die-with-parent --new-session --unshare-all --share-net \
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
  --setenv GH_TOKEN "$gh_pat_token" \
  copilot
