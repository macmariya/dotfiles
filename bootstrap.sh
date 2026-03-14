#!/bin/zsh
# bootstrap.sh — dotfiles 環境セットアップスクリプト
# 冪等性を保証: 既にインストール済みの場合はスキップ
set -euo pipefail

# ---------------------------------------------------------------------------
# 定数 / ディレクトリ検出
# ---------------------------------------------------------------------------
# スクリプト自身の絶対パスから dotfiles ルートを自動検出
DOTFILES="${0:A:h}"
STOW_PACKAGES=(zsh git tmux nvim ghostty bin)
OMZ_DIR="${HOME}/.oh-my-zsh"
OMZ_CUSTOM="${OMZ_DIR}/custom/plugins"
TPM_DIR="${HOME}/.tmux/plugins/tpm"

# ---------------------------------------------------------------------------
# カラー付きログ出力関数
# ---------------------------------------------------------------------------
_log() {
  local color="$1" label="$2"
  shift 2
  printf "%b[%s]%b %s\n" "$color" "$label" "\033[0m" "$*"
}
info()    { _log "\033[0;34m" "INFO"    "$@"; }
success() { _log "\033[0;32m" "OK"      "$@"; }
warn()    { _log "\033[0;33m" "WARN"    "$@"; }
error()   { _log "\033[0;31m" "ERROR"   "$@"; }

# フェーズ見出し表示
phase() {
  printf "\n%b==> Phase %s: %s%b\n" "\033[1;36m" "$1" "$2" "\033[0m"
}

# ---------------------------------------------------------------------------
# Phase 1: Xcode Command Line Tools
# ---------------------------------------------------------------------------
phase 1 "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
  success "Xcode CLT は既にインストール済みです"
else
  info "Xcode Command Line Tools をインストールします..."
  # ソフトウェアアップデート経由でインストール（GUI プロンプトが表示される）
  xcode-select --install 2>/dev/null || true
  # インストール完了を待機
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  success "Xcode CLT のインストールが完了しました"
fi

# ---------------------------------------------------------------------------
# Phase 2: Homebrew（Apple Silicon 対応）
# ---------------------------------------------------------------------------
phase 2 "Homebrew"

if command -v brew &>/dev/null; then
  success "Homebrew は既にインストール済みです: $(brew --version | head -1)"
else
  info "Homebrew をインストールします..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon: /opt/homebrew を PATH に追加（現セッション用）
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  success "Homebrew のインストールが完了しました"
fi

# ---------------------------------------------------------------------------
# Phase 3: Brewfile からパッケージインストール
# ---------------------------------------------------------------------------
phase 3 "Brewfile パッケージインストール"

BREWFILE="${DOTFILES}/Brewfile"
if [[ -f "$BREWFILE" ]]; then
  info "brew bundle を実行します: ${BREWFILE}"
  brew bundle --file="$BREWFILE" --no-lock
  success "Brewfile のインストールが完了しました"
else
  warn "Brewfile が見つかりません: ${BREWFILE} — スキップします"
fi

# ---------------------------------------------------------------------------
# Phase 4: Oh My Zsh
# ---------------------------------------------------------------------------
phase 4 "Oh My Zsh"

if [[ -d "$OMZ_DIR" ]]; then
  success "Oh My Zsh は既にインストール済みです"
else
  info "Oh My Zsh をインストールします（unattended モード）..."
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
  success "Oh My Zsh のインストールが完了しました"
fi

# ---------------------------------------------------------------------------
# Phase 5: Oh My Zsh カスタムプラグイン
# ---------------------------------------------------------------------------
phase 5 "Oh My Zsh カスタムプラグイン"

_install_omz_plugin() {
  local name="$1" repo="$2"
  local dest="${OMZ_CUSTOM}/${name}"
  if [[ -d "$dest" ]]; then
    success "${name} は既にインストール済みです"
  else
    info "${name} をインストールします..."
    git clone --depth=1 "$repo" "$dest"
    success "${name} のインストールが完了しました"
  fi
}

mkdir -p "$OMZ_CUSTOM"
_install_omz_plugin "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git"
_install_omz_plugin "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions.git"

# ---------------------------------------------------------------------------
# Phase 6: GNU Stow でシンボリックリンクを作成
# ---------------------------------------------------------------------------
phase 6 "GNU Stow シンボリックリンク"

if ! command -v stow &>/dev/null; then
  warn "stow コマンドが見つかりません — Phase 3 が正常に完了しているか確認してください"
else
  for pkg in "${STOW_PACKAGES[@]}"; do
    pkg_dir="${DOTFILES}/${pkg}"
    if [[ -d "$pkg_dir" ]]; then
      info "stow: ${pkg}"
      # --restow で既存リンクを更新、--target でホームディレクトリを明示
      stow --restow --target="${HOME}" --dir="${DOTFILES}" "$pkg"
      success "stow 完了: ${pkg}"
    else
      warn "${pkg} ディレクトリが見つかりません — スキップします"
    fi
  done
fi

# ---------------------------------------------------------------------------
# Phase 7: シークレット設定チェック（Keychain）
# ---------------------------------------------------------------------------
phase 7 "シークレット設定チェック"

_check_keychain() {
  local service="$1" account="$2" label="$3"
  if security find-generic-password -s "$service" -a "$account" &>/dev/null; then
    success "Keychain: ${label} は登録済みです"
  else
    warn "Keychain: ${label} が未登録です"
    warn "  → ${DOTFILES}/secrets/setup-secrets.sh を実行してください"
  fi
}

_check_keychain "github-pat" "${USER}" "GitHub PAT"

# ---------------------------------------------------------------------------
# Phase 8: macOS システム設定
# ---------------------------------------------------------------------------
phase 8 "macOS システム設定"

MACOS_SCRIPT="${DOTFILES}/macos.sh"
if [[ ! -f "$MACOS_SCRIPT" ]]; then
  warn "macos.sh が見つかりません — スキップします"
else
  printf "\n%b macOS のシステム設定を適用しますか？ (y/N): %b" "\033[1;33m" "\033[0m"
  read -r _reply
  if [[ "${_reply}" =~ ^[Yy]$ ]]; then
    info "macos.sh を実行します..."
    zsh "$MACOS_SCRIPT"
    success "macOS 設定が完了しました"
  else
    info "macOS 設定をスキップしました（後で 'make macos' で適用できます）"
  fi
fi

# ---------------------------------------------------------------------------
# Phase 9: TPM（Tmux Plugin Manager）
# ---------------------------------------------------------------------------
phase 9 "TPM (Tmux Plugin Manager)"

if [[ -d "$TPM_DIR" ]]; then
  success "TPM は既にインストール済みです"
else
  info "TPM をインストールします..."
  mkdir -p "${HOME}/.tmux/plugins"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  success "TPM のインストールが完了しました"
  info "tmux 内で prefix + I を押してプラグインをインストールしてください"
fi

# ---------------------------------------------------------------------------
# 完了メッセージ
# ---------------------------------------------------------------------------
printf "\n%b========================================%b\n" "\033[1;32m" "\033[0m"
printf "%b  dotfiles セットアップが完了しました!%b\n"   "\033[1;32m" "\033[0m"
printf "%b========================================%b\n" "\033[1;32m" "\033[0m"
printf "\n次のステップ:\n"
printf "  1. zsh を再起動: exec zsh\n"
printf "  2. シークレット未登録の場合: %s/secrets/setup-secrets.sh\n" "$DOTFILES"
printf "  3. tmux プラグイン: tmux 起動後に prefix + I\n\n"
