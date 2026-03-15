# dotfiles

MacBook Pro (Apple Silicon M5) / macOS Tahoe 向けの dotfiles。GNU Stow でモジュラー管理し、`bootstrap.sh` 一発で再現可能な開発環境を構築する。

<!-- スクリーンショット: ターミナルの見た目を貼る場合はここに -->
<!-- ![screenshot](https://example.com/screenshot.png) -->

## 特徴

- **Apple Silicon (M5) 最適化** -- Homebrew `/opt/homebrew` パス、macOS ネイティブ設定を自動適用
- **GNU Stow によるモジュラー管理** -- パッケージ単位でシンボリックリンクを作成・削除
- **nvm 遅延ロードでシェル起動 0.36 秒** -- nvm/node/npm/npx を初回呼び出し時にロード
- **macOS Keychain によるシークレット管理** -- PAT やAPIキーをファイルに残さず安全に保管
- **日本語環境完全対応** -- ハイブリッドロケール（UI: 英語、日時・通貨: 日本語）、HackGen Console NF フォント
- **Brewfile による再現可能な環境構築** -- CLI ツール、GUI アプリ、フォントを一括管理
- **SSH セキュリティ強化** -- Ed25519 デフォルト鍵、macOS Keychain 連携、暗号化アルゴリズム制限、config.d/ によるモジュラー構成
- **OrbStack による軽量 Docker 環境** -- Docker Desktop の約 1/3 のメモリで Docker CLI 完全互換

## 必要条件

| 項目 | バージョン |
|------|-----------|
| macOS | Tahoe (26.x) 以降 |
| チップ | Apple Silicon (M1 以降) |
| Xcode CLT | `xcode-select --install` で導入 |

> Xcode Command Line Tools は `bootstrap.sh` が自動インストールするため、事前導入は不要。

## インストール

```bash
# 1. リポジトリをクローン
git clone https://github.com/<your-username>/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles

# 2. 初回セットアップ（10フェーズ、冪等）
chmod +x bootstrap.sh
./bootstrap.sh

# 3. シークレットを Keychain に登録
chmod +x secrets/setup-secrets.sh
./secrets/setup-secrets.sh

# 4. シェルを再起動
exec zsh
```

`bootstrap.sh` は以下の 10 フェーズを順に実行する。すべて冪等で、再実行しても安全。

| Phase | 内容 |
|-------|------|
| 1 | Xcode Command Line Tools |
| 2 | Homebrew（Apple Silicon 対応） |
| 3 | Brewfile からパッケージインストール |
| 4 | Oh My Zsh |
| 5 | Oh My Zsh カスタムプラグイン（syntax-highlighting, autosuggestions） |
| 6 | GNU Stow でシンボリックリンク作成 |
| 7 | SSH 設定（Ed25519 デフォルト、パーミッション修正） |
| 8 | シークレット設定チェック（Keychain） |
| 9 | macOS システム設定（対話式、スキップ可） |
| 10 | Claude Code（スタンドアロンインストーラー） |

## 使い方

日常的な操作は `make` コマンドで行う。

```bash
make help    # コマンド一覧を表示
```

| コマンド | 説明 |
|---------|------|
| `make install` | `bootstrap.sh` を実行して初期セットアップ |
| `make update` | Homebrew 更新 + シンボリックリンク再作成 |
| `make stow` | 全パッケージのシンボリックリンクを作成・更新 |
| `make unstow` | 全パッケージのシンボリックリンクを削除 |
| `make brew` | Brewfile を適用してパッケージをインストール |
| `make brew-dump` | 現在のパッケージ構成を Brewfile に書き出す |
| `make macos` | macOS システム設定を適用（`macos.sh`） |
| `make clean` | 壊れたシンボリックリンクを検出・一覧表示 |
| `make ssh-fix` | SSH ディレクトリのパーミッションを修正 |

## Stow パッケージ

各ディレクトリが独立した Stow パッケージとして管理されている。個別に `stow <pkg>` / `stow -D <pkg>` で操作可能。

| パッケージ | 内容 | 主要設定 |
|-----------|------|---------|
| `zsh` | シェル設定 | Oh My Zsh + agnoster テーマ、モジュール分割（exports/path/aliases/completion/functions） |
| `git` | Git 設定 | 日本語対応（`quotepath=false`）、histogram diff、`~/.gitconfig.local` による拡張 |
| `tmux` | tmux 設定 | True Color、vim 風キーバインド、Catppuccin Mocha テーマ |
| `ghostty` | Ghostty ターミナル | HackGen Console NF 14pt、Catppuccin Mocha、透過タイトルバー |
| `nvim` | Neovim | lazy.nvim + 29 プラグイン（LSP, 補完, Telescope, Treesitter, Catppuccin Mocha） |
| `ssh` | SSH 設定 | Ed25519 デフォルト、macOS Keychain 連携、暗号化アルゴリズム制限、Ghostty 文字崩れ対策、config.d/ によるモジュラー構成 |

## ディレクトリ構成

```
dotfiles/
├── bootstrap.sh              # 初回セットアップ（10フェーズ、冪等）
├── Brewfile                   # Homebrew パッケージ一覧
├── Makefile                   # make コマンド集
├── macos.sh                   # macOS システム設定
├── zsh/                       # zsh シェル設定
│   ├── .zshrc                 # エントリポイント（モジュールローダー）
│   ├── .zprofile              # Homebrew shellenv
│   └── .config/zsh/
│       ├── aliases.zsh        # エイリアス定義
│       ├── completion.zsh     # 補完設定（24h キャッシュ）
│       ├── exports.zsh        # 環境変数（ハイブリッドロケール）
│       ├── functions.zsh      # ユーティリティ関数
│       ├── local.zsh.example  # マシン固有設定テンプレート
│       └── path.zsh           # PATH 設定・nvm 遅延ロード
├── git/                       # Git 設定
│   ├── .gitconfig             # メイン設定
│   └── .config/git/ignore     # グローバル gitignore
├── tmux/                      # tmux 設定
│   └── .tmux.conf
├── ghostty/                   # Ghostty ターミナル設定
│   └── .config/ghostty/config
├── nvim/                      # Neovim（lazy.nvim ベース）
│   └── .config/nvim/
│       ├── init.lua           # エントリポイント
│       └── lua/
│           ├── config/        # options, keymaps, autocmds, lazy
│           └── plugins/       # 13 プラグイン設定ファイル
├── ssh/                       # SSH 設定
│   └── .ssh/
│       ├── config             # SSH クライアント設定
│       └── config.d/          # ホスト固有設定（.gitignore 対象）
├── secrets/                   # .gitignore 対象
│   └── setup-secrets.sh       # Keychain 登録スクリプト
└── bin/                       # カスタムスクリプト
    └── .local/bin/
```

## カスタマイズ

### マシン固有のシェル設定

`zsh/.config/zsh/local.zsh.example` をコピーして使う。`local.zsh` は `.gitignore` 対象のため、マシン固有の設定を安全に追加できる。

```bash
cp zsh/.config/zsh/local.zsh.example zsh/.config/zsh/local.zsh
nvim zsh/.config/zsh/local.zsh
```

### マシン固有の Git 設定

`.gitconfig` の末尾で `~/.gitconfig.local` を `include` している。署名設定や仕事用メールアドレスなど、公開したくない設定はここに書く。

```bash
nvim ~/.gitconfig.local
```

```ini
# ~/.gitconfig.local の例
[user]
    signingkey = XXXXXXXXXXXXXXXX
[commit]
    gpgsign = true
```

## シークレット管理

API キーやトークンは **macOS Keychain** に保存し、シェル起動時に `security` コマンドで取得する。ファイルシステムにシークレットが残らない。

```bash
# 登録（対話式）
./secrets/setup-secrets.sh

# 手動で登録する場合
security add-generic-password -s "github-pat" -a "$USER" -l "GitHub PAT" -w

# 取得（zsh 設定で自動実行される）
security find-generic-password -s "github-pat" -a "$USER" -w
```

新しいシークレットを追加する場合は `secrets/setup-secrets.sh` にセクションを追加し、`zsh/.config/zsh/exports.zsh` に取得用の `export` 行を追加する。

## バックアップと復元

### 新しい Mac への移行

```bash
# 1. 新しい Mac でリポジトリをクローン
git clone https://github.com/<your-username>/dotfiles.git ~/dev/dotfiles

# 2. セットアップ実行
cd ~/dev/dotfiles
./bootstrap.sh

# 3. シークレットを再登録
./secrets/setup-secrets.sh
```

### Brewfile の更新

新しいパッケージをインストールした後、Brewfile を同期する。

```bash
make brew-dump
git add Brewfile
git commit -m "Brewfile を更新"
```

### Stow パッケージの追加

新しいツールの設定を追加する場合。

```bash
# 1. パッケージディレクトリを作成（ホームからの相対パスを再現）
mkdir -p newpkg/.config/newpkg
nvim newpkg/.config/newpkg/config

# 2. Makefile の STOW_PACKAGES と bootstrap.sh の STOW_PACKAGES に追加
# 3. リンク作成
stow --restow --target=$HOME newpkg
```

## Neovim

lazy.nvim をプラグインマネージャとして使用し、29 個のプラグインを遅延読み込みで管理している。初回起動時にプラグインと LSP サーバーが自動インストールされる。

### 主要プラグイン

| カテゴリ | プラグイン | 用途 |
|----------|-----------|------|
| テーマ | catppuccin | Mocha フレーバー（Ghostty / tmux と統一） |
| LSP | mason + lspconfig | 8 言語サーバー自動管理（Lua, TS, Python, Bash, JSON, YAML, HTML, CSS） |
| 補完 | nvim-cmp + LuaSnip | LSP / スニペット / バッファ / パス / コマンドライン補完 |
| 検索 | telescope + fzf-native | ファイル検索、テキスト検索、バッファ一覧、診断一覧 |
| ファイル | neo-tree | サイドバー型ファイルエクスプローラー |
| 構文 | treesitter | 16 言語のハイライト・インデント |
| Git | gitsigns | 差分サイン表示、hunk 操作 |
| 編集 | autopairs, Comment.nvim | 括弧自動閉じ、コメントトグル |
| UI | lualine, which-key, indent-blankline | ステータスライン、キーヒント、インデントガイド |

### 主要キーマップ（Leader = Space）

| キー | 動作 |
|------|------|
| `<leader>ff` | ファイル検索 |
| `<leader>fg` | テキスト検索（grep） |
| `<leader>e` | ファイルツリートグル |
| `gd` / `gr` | 定義 / 参照ジャンプ |
| `K` | ホバー情報 |
| `<leader>ca` | コードアクション |
| `<leader>rn` | リネーム |
| `gcc` | コメントトグル（行） |
| `]d` / `[d` | 次 / 前の診断へ |
| `]h` / `[h` | 次 / 前の Git hunk へ |

## ライセンス

[MIT](https://opensource.org/licenses/MIT)
