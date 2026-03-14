#!/bin/zsh
# setup-secrets.sh — Keychain へのシークレット登録スクリプト
# 対話形式で GitHub PAT などを macOS Keychain に安全に保存します
set -euo pipefail

# ---------------------------------------------------------------------------
# カラー付きログ出力関数
# ---------------------------------------------------------------------------
info()    { printf "\033[0;34m[INFO]\033[0m %s\n" "$*"; }
success() { printf "\033[0;32m[OK]\033[0m %s\n" "$*"; }
warn()    { printf "\033[0;33m[WARN]\033[0m %s\n" "$*"; }
error()   { printf "\033[0;31m[ERROR]\033[0m %s\n" "$*" >&2; }

# ---------------------------------------------------------------------------
# Keychain へのパスワード登録ヘルパー関数
# ---------------------------------------------------------------------------
# 引数: <service> <account> <label> <password>
_save_to_keychain() {
  local service="$1" account="$2" label="$3" password="$4"

  # 既存エントリを削除してから新規登録（冪等性を保証）
  security delete-generic-password -s "$service" -a "$account" &>/dev/null || true
  security add-generic-password \
    -s "$service" \
    -a "$account" \
    -l "$label" \
    -w "$password"
}

# ---------------------------------------------------------------------------
# ヘッダー表示
# ---------------------------------------------------------------------------
printf "\n\033[1;36m============================================\033[0m\n"
printf "\033[1;36m  dotfiles シークレット登録スクリプト\033[0m\n"
printf "\033[1;36m============================================\033[0m\n\n"
info "入力された値は画面に表示されません（非表示入力）"
info "Keychain に保存されます — ファイルには書き込まれません"
printf "\n"

# ---------------------------------------------------------------------------
# GitHub Personal Access Token の登録
# ---------------------------------------------------------------------------
printf "\033[1;33m--- GitHub Personal Access Token (PAT) ---\033[0m\n"
info "GitHub PAT は https://github.com/settings/tokens で生成できます"
info "必要なスコープ: repo, read:org, workflow"
printf "\n"

printf "GitHub PAT を入力してください (非表示): "
read -rs GITHUB_PAT
printf "\n"

if [[ -z "$GITHUB_PAT" ]]; then
  warn "入力が空のため GitHub PAT の登録をスキップします"
else
  _save_to_keychain "github-pat" "${USER}" "GitHub Personal Access Token" "$GITHUB_PAT"
  success "GitHub PAT を Keychain に登録しました"
  info "  Service : github-pat"
  info "  Account : ${USER}"
  # 確認: パスワードを取得してマスク表示
  _stored=$(security find-generic-password -s "github-pat" -a "${USER}" -w 2>/dev/null || echo "")
  if [[ -n "$_stored" ]]; then
    success "登録確認: 先頭4文字 = ${_stored:0:4}****"
  fi
fi

printf "\n"

# ---------------------------------------------------------------------------
# 追加シークレット（必要に応じて拡張してください）
# ---------------------------------------------------------------------------
# 例: OpenAI API Key
# printf "\033[1;33m--- OpenAI API Key ---\033[0m\n"
# printf "OpenAI API Key を入力してください (非表示): "
# read -rs OPENAI_KEY
# printf "\n"
# if [[ -n "$OPENAI_KEY" ]]; then
#   _save_to_keychain "openai-api-key" "${USER}" "OpenAI API Key" "$OPENAI_KEY"
#   success "OpenAI API Key を Keychain に登録しました"
# fi

# ---------------------------------------------------------------------------
# 完了メッセージ
# ---------------------------------------------------------------------------
printf "\n\033[1;32m============================================\033[0m\n"
printf "\033[1;32m  シークレット登録が完了しました\033[0m\n"
printf "\033[1;32m============================================\033[0m\n\n"
info "登録済みシークレットの確認コマンド:"
printf "  security find-generic-password -s github-pat -a %s -w\n\n" "${USER}"
info "Keychain からシークレットを取得するには (zsh 設定例):"
printf "  export GITHUB_TOKEN=\$(security find-generic-password -s github-pat -a %s -w)\n\n" "${USER}"
