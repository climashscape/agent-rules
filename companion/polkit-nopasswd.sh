#!/usr/bin/env bash
#
# polkit-nopasswd.sh — let members of a group run root commands through pkexec
# without a password prompt.
#
# Why this exists: desktop tools often ship a polkit action of their own
# (timeshift, update-alternatives, ...). Those actions ask for a password every
# time, which stops unattended scripts. `pkexec <program>` falls back to the
# generic action org.freedesktop.policykit.exec when the program has no action of
# its own, so granting that one generic action to a group keeps
# `pkexec bash -c '...'` working with nobody at the keyboard.
#
# Security: this lets every member of the group become root without a password.
# That is the point, and the risk. Keep the group small, and read the rule
# before installing it.
#
# Usage:
#   sudo bash polkit-nopasswd.sh                    install for group "sudo"
#   sudo bash polkit-nopasswd.sh --group wheel      pick another group
#   sudo bash polkit-nopasswd.sh --dry-run          print the rule, write nothing
#   sudo bash polkit-nopasswd.sh --uninstall        remove the rule
#
# This script is deliberately written to probe first and fail loudly: it checks
# for pkexec, the polkit rules directory and the group before touching anything.
#
set -euo pipefail

GROUP=sudo
RULE_DIR=/etc/polkit-1/rules.d
RULE_FILE=
ACTION=install
DRY_RUN=0

say()  { printf '%s\n' "$*"; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# Keep the original arguments and an absolute path to this script: pkexec switches
# the working directory to /root, so a relative path stops resolving.
ORIG_ARGS=("$@")
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

while [ $# -gt 0 ]; do
  case "$1" in
    -g|--group) GROUP="${2:?--group needs a value}"; shift 2 ;;
    -f|--file)  RULE_FILE="${2:?--file needs a value}"; shift 2 ;;
    --uninstall) ACTION=uninstall; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '3,26p' "$0" | sed 's/^#\{1,\} \{0,1\}//'; exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done
RULE_FILE="${RULE_FILE:-$RULE_DIR/49-pkexec-nopasswd.rules}"

render_rule() {
  cat <<EOF
// Installed by polkit-nopasswd.sh — grants the generic pkexec action to the
// "$GROUP" group so unattended scripts can run root commands silently.
// Remove this file (or run the script with --uninstall) to revoke it.
polkit.addRule(function(action, subject) {
    if (action.id === "org.freedesktop.policykit.exec" &&
        subject.isInGroup("$GROUP")) {
        return polkit.Result.YES;
    }
});
EOF
}

# ---- probes ---------------------------------------------------------------
[ "$(id -u)" -eq 0 ] || die "must run as root — try: pkexec bash $SCRIPT_PATH ${ORIG_ARGS[*]:-}"
have pkexec || die "pkexec not found — install polkit first"
[ -d "$RULE_DIR" ] || die "$RULE_DIR not found — polkit older than 0.106, or a non-standard layout; set --file to your rules directory"
if [ "$ACTION" = install ]; then
  getent group "$GROUP" >/dev/null || die "group '$GROUP' does not exist here (check: getent group | cut -d: -f1)"
  say "polkit rules dir : $RULE_DIR"
  say "target rule file : $RULE_FILE"
  say "group granted    : $GROUP"
fi

# ---- act ------------------------------------------------------------------
if [ "$ACTION" = uninstall ]; then
  if [ -f "$RULE_FILE" ]; then
    rm -f "$RULE_FILE"
    say "removed $RULE_FILE — polkit reloads rules automatically"
  else
    say "nothing to do: $RULE_FILE does not exist"
  fi
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  say "--- dry run: the following would be written to $RULE_FILE ---"
  render_rule
  exit 0
fi

if [ -f "$RULE_FILE" ] && diff -q <(render_rule) "$RULE_FILE" >/dev/null 2>&1; then
  say "already installed and identical — nothing to do"
  exit 0
fi

if [ -f "$RULE_FILE" ]; then
  cp -a "$RULE_FILE" "$RULE_FILE.bak.$(date +%Y%m%d%H%M%S)"
  say "existing file backed up next to it"
fi

render_rule > "$RULE_FILE"
chmod 644 "$RULE_FILE"
say "installed $RULE_FILE"

# ---- verify --------------------------------------------------------------
cat <<EOF

Verify from a NON-root shell (as the group member, not as root):

    pkexec bash -c 'id -u'      # expect: 0, with no password prompt

If it still prompts, polkit did not match the rule — check that the user is
really in '$GROUP' (id -nG) and that no earlier rule file returns NO first.
EOF
