# exports.zsh - 環境変数の定義
# ロケール、エディタ、認証情報などの共通設定

# --- ロケール設定（ハイブリッド方式）---
# UIは英語、日時・通貨は日本語
export LANG=en_US.UTF-8
export LC_TIME=ja_JP.UTF-8
export LC_MONETARY=ja_JP.UTF-8
export LC_NUMERIC=ja_JP.UTF-8
export LESSCHARSET=utf-8

# --- エディタ ---
export EDITOR="nvim"
export VISUAL="$EDITOR"

# --- GitHub PAT（Keychainから必要時に取得する関数方式）---
# 環境変数への常駐を避け、呼び出し時のみ Keychain にアクセスする
github-pat() {
  security find-generic-password -a "$USER" -s "github-pat" -w 2>/dev/null
}
