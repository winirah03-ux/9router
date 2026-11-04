#!/bin/sh
set -eu

chown -R node:node /app/data /app/data-home 2>/dev/null || true

if [ -n "${SSH_PASSWORD:-}" ]; then
  if [ "${#SSH_PASSWORD}" -lt 16 ]; then
    echo "SSH_PASSWORD must contain at least 16 characters" >&2
    exit 1
  fi

  newline='
'
  case "$SSH_PASSWORD" in
    *:*|*"$newline"*)
      echo "SSH_PASSWORD cannot contain ':' or newlines" >&2
      exit 1
      ;;
  esac

  printf 'node:%s\n' "$SSH_PASSWORD" | chpasswd
  ssh-keygen -A
  /usr/sbin/sshd -t
  /usr/sbin/sshd -e
  unset SSH_PASSWORD
fi

exec su-exec node "$@"