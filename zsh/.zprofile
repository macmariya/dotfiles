# .zprofile - ログインシェル初期化
# Homebrew環境変数の設定（Apple Silicon / Intel 両対応）

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
