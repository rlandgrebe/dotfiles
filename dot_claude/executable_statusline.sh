#!/bin/bash
# Claude Code Status Line
set -f -u -o pipefail

input=$(cat)
[ -z "$input" ] && printf "Claude" && exit 0

# ── Colors ──────────────────────────────────────────────
cyan='\033[38;2;86;182;194m'
yellow='\033[38;2;230;200;0m'
dim='\033[2m'
reset='\033[0m'
sep=" ${dim}│${reset} "

# ── Helpers ─────────────────────────────────────────────
format_tokens() {
    LC_NUMERIC=C awk -v n="$1" 'BEGIN {
        if (n >= 1e6)      { v=n/1e6; printf (v==int(v) ? "%.0fm" : "%.1fm"), v }
        else if (n >= 1e3) { printf "%.0fk", n/1e3 }
        else               { printf "%d", n }
    }'
}

format_reset_time() {
    local epoch="$1" style="$2"
    [ -z "$epoch" ] || [ "$epoch" = "null" ] && return
    [ "$epoch" -le 0 ] 2>/dev/null && return
    case "$style" in
        time)
            date -j -r "$epoch" +"%H:%M" 2>/dev/null \
              || date -d "@$epoch" +"%H:%M" 2>/dev/null
            ;;
        datetime)
            LC_TIME=de_DE.UTF-8 date -j -r "$epoch" +"%a %H:%M" 2>/dev/null \
              || LC_TIME=de_DE.UTF-8 date -d "@$epoch" +"%a %H:%M" 2>/dev/null
            ;;
    esac
}

# ── Extract ─────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.cwd // ""')
in_tok=$(echo "$input"  | jq -r '.context_window.current_usage.input_tokens // 0')
out_tok=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
cc_tok=$(echo "$input"  | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cr_tok=$(echo "$input"  | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
pct_used=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | awk '{printf "%.0f", $1}')

current=$(( in_tok + out_tok + cc_tok + cr_tok ))
used_tokens=$(format_tokens "$current")

five_pct=$(echo "$input"    | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_pct=$(echo "$input"    | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ── Folder ──────────────────────────────────────────────
out="${cyan}${cwd##*/}${reset}"

# ── Branch ──────────────────────────────────────────────
if [ -n "$cwd" ]; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        branch=$(printf '%s' "$branch" | tr -d '\000-\037\177')
        [ "${#branch}" -gt 28 ] && branch="${branch:0:27}…"
        out+="${sep}${dim}⎇${reset} ${yellow}${branch}${reset}"
    fi
fi

# ── Tokens ──────────────────────────────────────────────
out+="${sep}${used_tokens} ${dim}${pct_used}%${reset}"

# ── Rate limits ─────────────────────────────────────────
for label in 5h 7d; do
    case "$label" in
        5h) pct=$five_pct;  resets=$five_resets;  style=time ;;
        7d) pct=$seven_pct; resets=$seven_resets; style=datetime ;;
    esac
    [ -z "$pct" ] && continue
    pct_fmt=$(printf '%s' "$pct" | awk '{printf "%.0f", $1}')
    out+="${sep}${cyan}${label}${reset} ${pct_fmt}%"
    rt=$(format_reset_time "$resets" "$style")
    [ -n "$rt" ] && out+=" ${dim}↺ ${rt}${reset}"
done

# ── Output ──────────────────────────────────────────────
printf "%b" "$out"
