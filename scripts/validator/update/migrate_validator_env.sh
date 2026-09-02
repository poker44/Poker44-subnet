#!/usr/bin/env bash

# Enforce the current network-wide full-burn allocation. This intentionally
# supersedes former defaults and custom transition allocations so every
# validator converges after applying the release.
set_validator_env_value() {
  local env_file="$1"
  local key="$2"
  local value="$3"
  local temporary

  temporary="$(mktemp "${env_file}.XXXXXX")"
  awk -v key="$key" -v value="$value" '
    $0 ~ "^[[:space:]]*(export[[:space:]]+)?" key "=" {
      print key "=" value
      next
    }
    { print }
  ' "$env_file" > "$temporary"
  mv "$temporary" "$env_file"
}

migrate_transition_burn_default() {
  local env_file="${1:-}"
  if [ -n "$env_file" ] && [ -f "$env_file" ]; then
    if grep -Eq '^[[:space:]]*(export[[:space:]]+)?POKER44_BURN_FRACTION=' "$env_file"; then
      set_validator_env_value "$env_file" POKER44_BURN_FRACTION 1.00
    else
      printf '%s\n' 'POKER44_BURN_FRACTION=1.00' >> "$env_file"
    fi
    if grep -Eq '^[[:space:]]*(export[[:space:]]+)?POKER44_FUNDING_FRACTION=' "$env_file"; then
      set_validator_env_value "$env_file" POKER44_FUNDING_FRACTION 0.00
    else
      printf '%s\n' 'POKER44_FUNDING_FRACTION=0.00' >> "$env_file"
    fi
    chmod 600 "$env_file"
  fi
  export POKER44_BURN_FRACTION="1.00"
  export POKER44_FUNDING_FRACTION="0.00"
  echo "[INFO] Applied full-burn allocation: burn=1.00 funding=0.00"
}
