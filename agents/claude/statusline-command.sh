#!/bin/bash
# Claude Code status line: path, git, context bar, session diff, model, limits
input=$(cat)

# Every value is forced to a single string before @sh, since @sh splits
# arrays into separate words, and control characters are stripped so
# nothing can inject terminal escapes
eval "$(jq -r '
  def s(f): (f // "") | if type == "string" then . else tojson end
    | gsub("[[:cntrl:]]"; "");
  def n(f): (f // "") | if type == "number" then floor | tostring else "" end;
  @sh "cwd=\(s(.workspace.current_dir // .cwd))
model=\(s(.model.display_name))
effort=\(s(.effort.level))
fast=\(.fast_mode == true | tostring)
ctx=\(n(.context_window.used_percentage))
added=\(n(.cost.total_lines_added))
removed=\(n(.cost.total_lines_removed))
rl5=\(n(.rate_limits.five_hour.used_percentage))
rl5_reset=\(n(.rate_limits.five_hour.resets_at))
rl7=\(n(.rate_limits.seven_day.used_percentage))
rl7_reset=\(n(.rate_limits.seven_day.resets_at))
worktree=\(s(.worktree.name // .workspace.git_worktree))
pr=\(n(.pr.number))
pr_state=\(s(.pr.review_state))
cold=\(.prompt_cache.caching_observed == true and .prompt_cache.warm == false | tostring)"
' <<<"$input")"

e=$'\033'
reset="$e[0m" dim="$e[2m" bold_green="$e[1;32m"
red="$e[31m" green="$e[32m" yellow="$e[33m" magenta="$e[35m" cyan="$e[36m"

# Green under 50%, yellow under 80%, red from 80%
level_color() {
  if [ "$1" -ge 80 ]; then printf '%s' "${red}"
  elif [ "$1" -ge 50 ]; then printf '%s' "${yellow}"
  else printf '%s' "${green}"; fi
}

# Epoch to local time; BSD date first, GNU date as fallback
fmt_time() {
  date -r "$1" "+$2" 2>/dev/null || date -d "@$1" "+$2" 2>/dev/null
}

parts=()

# Current folder name only
dir="${cwd/#$HOME/~}"
dir="${dir##*/}"
[ -z "$dir" ] && dir="/"
location="${bold_green}$dir${reset}"

# Git: one status call gives branch, ahead/behind and dirty state
if git_out=$(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
  head="" oid="" ahead=0 behind=0 dirty=""
  while IFS= read -r line; do
    case "$line" in
      "# branch.head "*) head="${line#\# branch.head }" ;;
      "# branch.oid "*) oid="${line#\# branch.oid }" ;;
      "# branch.ab "*) read -r _ _ a b <<<"$line"; ahead="${a#+}"; behind="${b#-}" ;;
      "#"*) ;;
      ?*) dirty=1 ;;
    esac
  done <<<"$git_out"
  [ "$head" = "(detached)" ] && head="${oid:0:7}"
  git_seg=" on ${magenta}"$'\xee\x82\xa0'" $head"
  [ -n "$dirty" ] && git_seg+="${red}!"
  sync=""
  [ "$ahead" -gt 0 ] && sync+="↑$ahead"
  [ "$behind" -gt 0 ] && sync+="↓$behind"
  [ -n "$sync" ] && git_seg+=" ${cyan}$sync"
  location+="$git_seg${reset}"
fi
[ -n "$worktree" ] && location+=" ${dim}⎇ $worktree${reset}"
if [ -n "$pr" ]; then
  case "$pr_state" in
    approved) pr_mark="${green}✓" ;;
    changes_requested) pr_mark="${red}✗" ;;
    *) pr_mark="${yellow}•" ;;
  esac
  location+=" ${dim}#$pr${reset}$pr_mark${reset}"
fi
parts+=("$location")

# Context window bar
pct="${ctx:-0}"
filled=$(((pct * 10 + 50) / 100))
[ "$pct" -gt 0 ] && [ "$filled" -eq 0 ] && filled=1
[ "$filled" -gt 10 ] && filled=10
used="" free=""
for ((i = 0; i < 10; i++)); do
  if [ "$i" -lt "$filled" ]; then used+="━"; else free+="━"; fi
done
color=$(level_color "$pct")
if [ -n "$ctx" ]; then
  parts+=("${color}$used${reset}${dim}$free${reset} ${color}$pct%${reset}")
else
  parts+=("${dim}$free --${reset}")
fi

# Session diff
if [ "${added:-0}" -gt 0 ] || [ "${removed:-0}" -gt 0 ]; then
  parts+=("${green}+${added:-0}${reset} ${red}−${removed:-0}${reset}")
fi

# Model, effort, fast mode, cold cache
meta="$model"
[ -n "$effort" ] && meta+=" · $effort"
meta_seg="${dim}$meta${reset}"
[ "$fast" = true ] && meta_seg+=" ${yellow}⚡${reset}"
[ "$cold" = true ] && meta_seg+=" ${cyan}❄${reset}"
parts+=("$meta_seg")

# Rate limits, shown from 50%, with reset time from 80%
if [ -n "$rl5" ] && [ "$rl5" -ge 50 ]; then
  seg="$(level_color "$rl5")5h $rl5%"
  [ "$rl5" -ge 80 ] && [ -n "$rl5_reset" ] && seg+=" ↻$(fmt_time "$rl5_reset" %H:%M)"
  parts+=("$seg${reset}")
fi
if [ -n "$rl7" ] && [ "$rl7" -ge 50 ]; then
  seg="$(level_color "$rl7")7d $rl7%"
  [ "$rl7" -ge 80 ] && [ -n "$rl7_reset" ] && seg+=" ↻$(fmt_time "$rl7_reset" '%a %H:%M')"
  parts+=("$seg${reset}")
fi

out=""
for part in "${parts[@]}"; do
  [ -n "$out" ] && out+="  "
  out+="$part"
done
printf '%s' "$out"
