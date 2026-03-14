# completion.zsh - 補完システムの設定
# compinit最適化、大文字小文字非区別、メニュー選択

# --- compinit（24時間キャッシュ）---
# .zcompdump を1日1回だけ再生成してシェル起動を高速化
autoload -Uz compinit

_comp_cache="$HOME/.zcompdump"
if [[ -f "$_comp_cache" ]] && [[ $(date +'%j') == $(stat -f '%Sm' -t '%j' "$_comp_cache" 2>/dev/null) ]]; then
  compinit -C  # キャッシュから読み込み（チェック省略）
else
  compinit      # 完全な初期化
fi
unset _comp_cache

# --- 補完スタイル ---
# 大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# メニュー選択モード（Tab連打で選択移動）
zstyle ':completion:*' menu select

# 補完候補にグループヘッダーを表示
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

# 補完候補の色付け（ls --colorと同様）
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# キャッシュを有効化（重い補完の高速化）
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

# 部分一致補完（途中の文字列でもマッチ）
zstyle ':completion:*' completer _complete _approximate
