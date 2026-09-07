#!/usr/bin/env bash
set -eou pipefail

bwrap --die-with-parent --new-session --unshare-all --share-net \
  --symlink usr/bin /bin \
  --symlink usr/lib /lib \
  --symlink usr/lib /lib64 \
  --ro-bind /usr /usr \
  --ro-bind /opt/claude-code/bin/claude /opt/claude-code/bin/claude \
  --proc /proc --dev /dev \
  --dir /etc \
  --ro-bind /etc/resolv.conf /etc/resolv.conf \
  --ro-bind /etc/hosts /etc/hosts \
  --ro-bind "$HOME/.claude.json" "$HOME/.claude.json" \
  --ro-bind "$HOME/.claude" "$HOME/.claude" \
  --bind-try "$HOME/.claude/.credentials.json" "$HOME/.claude/.credentials.json" \
  --bind-try "$HOME/.claude/sessions" "$HOME/.claude/sessions" \
  --bind-try "$HOME/projects" "$HOME/projects" \
  --bind-try "$HOME/workspace" "$HOME/workspace" \
  claude
