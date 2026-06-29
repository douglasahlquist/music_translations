#!/usr/bin/env bash
#
# mdtable.sh — generate a Markdown table file with a title and an editable link row.
#
# Usage:
#   ./mdtable.sh <rows> <cols> [output_file] [title]
#
# Arguments:
#   rows         Number of body rows in the table (must be >= 1).
#   cols         Number of columns in the table (must be >= 1).
#   output_file  Optional. Path to write the table to.   Default: table.md
#   title        Optional. Title shown above the table.  Default: "Table Title"
#
# The first body row (the second rendered row of the table) is pre-filled with
# placeholder Markdown links pointing at example.com, so you can find-and-replace
# them with real URLs by hand.

set -euo pipefail

# ----- colors (only when stdout is a TTY) ------------------------------------
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
else
  BOLD=""; RED=""; GREEN=""; YELLOW=""; RESET=""
fi

usage() {
  cat <<EOF
${BOLD}Usage:${RESET} $(basename "$0") <rows> <cols> [output_file] [title]

  ${BOLD}rows${RESET}         Number of body rows (>= 1)
  ${BOLD}cols${RESET}         Number of columns (>= 1)
  ${BOLD}output_file${RESET}  Output path (default: table.md)
  ${BOLD}title${RESET}        Title above the table (default: "Table Title")

Example:
  $(basename "$0") 4 3 report.md "Quarterly Report"
EOF
}

die() { printf '%s%s%s\n' "$RED" "$1" "$RESET" >&2; exit 1; }

is_pos_int() { [[ "$1" =~ ^[1-9][0-9]*$ ]]; }

# ----- parse + validate args -------------------------------------------------
if [[ $# -lt 2 ]]; then
  usage >&2
  exit 1
fi

rows="$1"
cols="$2"
outfile="${3:-table.md}"
title="${4:-Table Title}"

is_pos_int "$rows" || die "rows must be a positive integer (got: '$rows')"
is_pos_int "$cols" || die "cols must be a positive integer (got: '$cols')"

# ----- build the table -------------------------------------------------------
{
  # Title row. Markdown tables can't span columns, so a heading above the table
  # is the portable way to give the whole table a title.
  printf '## %s\n\n' "$title"

  printf '<!-- Replace the example.com links in the first row with real URLs. -->\n\n'

  # Header row
  printf '|'
  for ((c = 1; c <= cols; c++)); do
    printf ' Column %d |' "$c"
  done
  printf '\n'

  # Separator row
  printf '|'
  for ((c = 1; c <= cols; c++)); do
    printf ' --- |'
  done
  printf '\n'

  # Body rows
  for ((r = 1; r <= rows; r++)); do
    printf '|'
    for ((c = 1; c <= cols; c++)); do
      if [[ $r -eq 1 ]]; then
        # Second rendered row (first body row): editable placeholder links.
        printf ' [Link %d](https://example.com/replace-me-%d) |' "$c" "$c"
      else
        printf ' Row %d Col %d |' "$r" "$c"
      fi
    done
    printf '\n'
  done
} > "$outfile"

printf '%s✓%s wrote %s%s%s (%s%d%s rows × %s%d%s cols)\n' \
  "$GREEN" "$RESET" "$BOLD" "$outfile" "$RESET" \
  "$YELLOW" "$rows" "$RESET" "$YELLOW" "$cols" "$RESET"
