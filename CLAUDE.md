# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

macOS (Apple Silicon) 限定のターミナル中心 AI 開発環境を構築するための dotfiles。GNU Stow でシンボリックリンクを管理し、`bootstrap.sh` で冪等なセットアップを提供する。

## コマンド

```bash
make stow          # シンボリックリンク作成・更新（ssh-fix も自動実行）
make unstow        # シンボリックリンク削除
make update        # brew update + upgrade + stow
make brew          # Brewfile 適用
make brew-dump     # 現在のパッケージを Brewfile に書き出し
make macos         # macOS システム設定適用
make ssh-fix       # ~/.ssh パーミッション修正
make clean         # 壊れたシンボリックリンク検出
make install       # bootstrap.sh 実行（全 10 フェーズ）
```

## アーキテクチャ

### GNU Stow パッケージ構造

各ディレクトリが `$HOME` へのシンボリックリンク元。`STOW_PACKAGES` は `.stow-packages` ファイルで一元管理されており、パッケージ追加時はこのファイルのみ更新すればよい。

### Stow の競合解決と tree folding 防止

`make stow` / `bootstrap.sh` ともに、既存の実ファイルとの競合時は `--adopt → git checkout → --restow` の3段階で安全に解決する。adopt でリポジトリ側が一時的にローカル版で上書きされるが、直後の `git checkout` でリポジトリの正しい内容に復元される。

tree folding（ディレクトリ単位のシンボリックリンク）を防止するため、`UNFOLD_DIRS`（Makefile）/ `mkdir -p`（bootstrap.sh）で `~/.config/zsh` と `~/.config/nvim` を事前に実ディレクトリとして作成する。これにより `local.zsh` やツール自動生成ファイルとの共存が可能。

`bootstrap.sh` では stow 前に `_rescue_zsh_config()` が既存の `.zshrc` の内容を `~/.config/zsh/local.zsh` に救出し、バックアップを `.stow-backup/` に保存する。

### シークレット管理

ファイルに残さず macOS Keychain に保存する方針。`exports.zsh` では環境変数への常駐を避け、関数方式 (`github-pat()`) で必要時のみ取得する。

### マシン固有設定の分離パターン

- シェル: `zsh/.config/zsh/local.zsh`（`.gitignore` 対象）
- Git: `~/.gitconfig.local`（`[include]` で読み込み）
- SSH: `~/.ssh/config.d/`（`.gitignore` 対象）

これらに個人情報・IP アドレス・接続先を書き、リポジトリには含めない。

### bootstrap.sh のフェーズ設計

全フェーズが冪等（`command -v` や `-d` チェックで既存をスキップ）。新フェーズ追加時は同じパターンを踏襲すること。

### zsh モジュール構成

`.zshrc` は以下の順序でモジュールをロードする: `exports` → `path` → `aliases` → `completion` → `functions` → `local.zsh`。シェル起動目標は 0.36s 以内。nvm/pyenv/rbenv は遅延ロード済みのため、`eval "$(xxx init)"` を追加しないこと。

### 環境

- Homebrew prefix: `/opt/homebrew`（Apple Silicon 専用パス）
- Git: `pull.rebase = true`（マージコミットは使わない）

## 変更時の注意

- **公開リポジトリ**: 実メールアドレス、IP アドレス、トークンをコミットしない。サンプルには `example.com` / RFC 予約アドレスを使用する
- **Neovim**: `lazy = true` がデフォルト。早期ロードが必要なプラグインのみ `lazy = false` を個別指定。Neovim 0.10+ API を使用する（`vim.fn.sign_define` は非推奨）
- **SSH config**: `SetEnv TERM=xterm-256color` は Ghostty の文字崩れ対策。削除しないこと
