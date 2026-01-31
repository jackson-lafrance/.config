: "${OLLAMA_SERVER:=http://100.80.185.91:11434}"

_slaade_hist_path() {
  local mode="$1"
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}"
  mkdir -p "$cache"
  echo "$cache/slaade-${mode}.json"
}

_slaade_clear_all_hist() {
  rm -f "$(_slaade_hist_path chat)" "$(_slaade_hist_path code)"
}

_slaade_system_prompt() {
  local mode="$1"
  if [[ "$mode" == "code" ]]; then
    printf '%s' "You are a senior software engineer. Be precise and practical. Prefer code over prose. Include edge cases. Ask at most one concise question only if absolutely necessary."
  else
    printf '%s' "You are my private offline assistant. Be accurate and concise. If unsure, say so. Do not invent prior messages; use the conversation history provided."
  fi
}

_slaade_py_chat() {
  local model="$1"
  local history_file="$2"
  local user_text="$3"
  local system_prompt="$4"

  OLLAMA_SERVER="$OLLAMA_SERVER" MODEL="$model" HISTORY_FILE="$history_file" USER_TEXT="$user_text" SYSTEM_PROMPT="$system_prompt" \
  python3 - <<'PY'
import os, json, pathlib, urllib.request, urllib.error

server = os.environ["OLLAMA_SERVER"].rstrip("/")
model = os.environ["MODEL"]
hist_path = pathlib.Path(os.environ["HISTORY_FILE"])
user_text = os.environ["USER_TEXT"]
system_prompt = os.environ["SYSTEM_PROMPT"]

def load_hist():
    if hist_path.exists():
        try:
            return json.loads(hist_path.read_text(encoding="utf-8"))
        except Exception:
            return []
    return []

def ensure_system(hist):
    if not hist or hist[0].get("role") != "system":
        return [{"role": "system", "content": system_prompt}] + hist
    hist[0]["content"] = system_prompt
    return hist

def trim(hist, max_msgs=40):
    sysmsg = hist[:1] if hist and hist[0].get("role") == "system" else []
    rest = hist[1:] if sysmsg else hist
    if len(rest) > max_msgs:
        rest = rest[-max_msgs:]
    return sysmsg + rest

hist = trim(ensure_system(load_hist()))
hist.append({"role": "user", "content": user_text})

payload = {
    "model": model,
    "stream": False,
    "keep_alive": "30m",
    "messages": hist
}

req = urllib.request.Request(
    server + "/api/chat",
    data=json.dumps(payload).encode("utf-8"),
    headers={"Content-Type": "application/json"},
    method="POST",
)

try:
    with urllib.request.urlopen(req, timeout=300) as resp:
        data = json.loads(resp.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    body = e.read().decode("utf-8", errors="ignore")
    raise SystemExit(f"HTTP {e.code}: {body}")
except Exception as e:
    raise SystemExit(str(e))

assistant = (data.get("message") or {}).get("content", "")
print(assistant, end="")

hist.append({"role": "assistant", "content": assistant})
hist = trim(hist, max_msgs=40)
hist_path.parent.mkdir(parents=True, exist_ok=True)
hist_path.write_text(json.dumps(hist, ensure_ascii=False), encoding="utf-8")
PY
}

_slaade_py_embed() {
  local text="$*"
  OLLAMA_SERVER="$OLLAMA_SERVER" USER_TEXT="$text" \
  python3 - <<'PY'
import os, json, urllib.request, urllib.error
server = os.environ["OLLAMA_SERVER"].rstrip("/")
text = os.environ["USER_TEXT"]
payload = {"model": "nomic-embed-text", "prompt": text}
req = urllib.request.Request(
    server + "/api/embeddings",
    data=json.dumps(payload).encode("utf-8"),
    headers={"Content-Type": "application/json"},
    method="POST",
)
try:
    with urllib.request.urlopen(req, timeout=300) as resp:
        data = json.loads(resp.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    body = e.read().decode("utf-8", errors="ignore")
    raise SystemExit(f"HTTP {e.code}: {body}")
vec = data.get("embedding", [])
print(len(vec))
print(vec)
PY
}

_slaade_cmd_suggestions() {
  local prefix="$1"
  local -a cmds
  cmds=(/clear /exit /quit /help)
  local -a matches
  matches=()
  local c
  for c in "${cmds[@]}"; do
    [[ "$c" == ${prefix}* ]] && matches+=("$c")
  done
  if (( ${#matches[@]} )); then
    printf "%s\n" "${matches[@]}"
  else
    printf "%s\n" "${cmds[@]}"
  fi
}

_slaade_repl() {
  local model="$1"
  local mode="$2"
  local hist="$(_slaade_hist_path "$mode")"
  local system="$(_slaade_system_prompt "$mode")"

  while true; do
    printf "> "
    IFS= read -r line || break

    if [[ "$line" == /* ]]; then
      case "$line" in
        /exit|/quit) break ;;
        /clear)
          _slaade_clear_all_hist
          printf "cleared\n"
          continue
          ;;
        /help)
          printf "%s\n" "commands:"
          _slaade_cmd_suggestions "/"
          continue
          ;;
        *)
          _slaade_cmd_suggestions "$line"
          continue
          ;;
      esac
    fi

    [[ -n "$line" ]] || continue

    _slaade_py_chat "$model" "$hist" "$line" "$system"
    printf "\n\n"
  done
}

slaade() {
  local sub="${1:-}"
  shift || true
  case "$sub" in
    chat)
      if [[ $# -eq 0 ]]; then
        _slaade_repl "llama3.1:8b" "chat"
      else
        local system="$(_slaade_system_prompt chat)"
        local tmp="${TMPDIR:-/tmp}/slaade-oneshot-$$.json"
        rm -f "$tmp"
        _slaade_py_chat "llama3.1:8b" "$tmp" "$*" "$system"
        rm -f "$tmp"
        printf "\n"
      fi
      ;;
    code)
      if [[ $# -eq 0 ]]; then
        _slaade_repl "codellama:34b" "code"
      else
        local system="$(_slaade_system_prompt code)"
        local tmp="${TMPDIR:-/tmp}/slaade-oneshot-$$.json"
        rm -f "$tmp"
        _slaade_py_chat "codellama:34b" "$tmp" "$*" "$system"
        rm -f "$tmp"
        printf "\n"
      fi
      ;;
    embed)
      [[ $# -gt 0 ]] || return 2
      _slaade_py_embed "$@"
      ;;
    *)
      return 2
      ;;
  esac
}

sl() { slaade "$@"; }

