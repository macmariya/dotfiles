# completion.zsh - 補完システムの設定
# compinit最適化、大文字小文字非区別、メニュー選択

# --- compinit（24時間キャッシュ）---
# Oh My Zsh が compinit を実行済みのため、ここでは補完スタイルの設定のみ行う
# OMZ の compinit 設定: ZSH_COMPDUMP を .zshrc で指定可能

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
mkdir -p "$HOME/.zsh/cache" 2>/dev/null
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

# 部分一致補完（途中の文字列でもマッチ）
zstyle ':completion:*' completer _complete _approximate
