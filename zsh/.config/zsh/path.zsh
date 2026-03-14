# path.zsh - PATH構成とツール初期化
# pyenv, nvm（遅延ロード）, rbenv, Codex CLI の設定

# --- pyenv ---
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT" ]] && {
  export PATH="$PYENV_ROOT/shims:$PATH"
  eval "$(pyenv init -)"
}

# --- rbenv ---
[[ -d "$HOME/.rbenv" ]] && {
  export PATH="$HOME/.rbenv/shims:$PATH"
  eval "$(rbenv init - zsh)"
}

# --- nvm（遅延ロード）---
# シェル起動を高速化するため、nvm/node/npm/npx の初回呼び出し時にロード
export NVM_DIR="$HOME/.nvm"

if [[ -d "$NVM_DIR" ]]; then
  # nvm関連コマンドのスタブを定義
  _nvm_lazy_cmds=(nvm node npm npx)

  _nvm_lazy_load() {
    # スタブ関数を削除
    for cmd in "${_nvm_lazy_cmds[@]}"; do
      unfunction "$cmd" 2>/dev/null
    done
    unset _nvm_lazy_cmds

    # nvmを実際にロード
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  }

  for _cmd in "${_nvm_lazy_cmds[@]}"; do
    eval "${_cmd}() { _nvm_lazy_load; ${_cmd} \"\$@\"; }"
  done
  unset _cmd
fi

# --- Codex CLI ---
export CODEX="$HOME/.codex"
[[ -f "$CODEX/completion-zsh.sh" ]] && source "$CODEX/completion-zsh.sh"

# --- 追加PATH ---
path=(
  "$HOME/.local/bin"
  $path
)

# 重複を除去
typeset -U path
