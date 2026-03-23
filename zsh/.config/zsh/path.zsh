# path.zsh - PATH構成とツール初期化
# pyenv, rbenv, nvm は遅延ロードでシェル起動を高速化

# --- pyenv（遅延ロード）---
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT" ]]; then
  path=("$PYENV_ROOT/shims" $path)
  pyenv() { unfunction pyenv; eval "$(command pyenv init -)"; pyenv "$@"; }
fi

# --- rbenv（遅延ロード）---
if [[ -d "$HOME/.rbenv" ]]; then
  path=("$HOME/.rbenv/shims" $path)
  rbenv() { unfunction rbenv; eval "$(command rbenv init - zsh)"; rbenv "$@"; }
fi

# --- nvm（遅延ロード）---
export NVM_DIR="$HOME/.nvm"

if [[ -d "$NVM_DIR" ]]; then
  _nvm_lazy_cmds=(nvm node npm npx)

  _nvm_lazy_load() {
    for cmd in "${_nvm_lazy_cmds[@]}"; do
      unfunction "$cmd" 2>/dev/null
    done
    unset _nvm_lazy_cmds
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  }

  for _cmd in "${_nvm_lazy_cmds[@]}"; do
    functions[$_cmd]="_nvm_lazy_load; command ${_cmd} \"\$@\""
  done
  unset _cmd
fi

# --- Codex CLI ---
_codex_dir="$HOME/.codex"
[[ -f "$_codex_dir/completion-zsh.sh" ]] && source "$_codex_dir/completion-zsh.sh"
unset _codex_dir

# --- 追加PATH ---
path=(
  "$HOME/.local/bin"
  $path
)

# 重複を除去
typeset -U path
