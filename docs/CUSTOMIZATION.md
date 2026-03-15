# カスタマイズガイド

このドキュメントは、dotfiles 環境をカスタマイズする方法を説明します。

---

## Stow パッケージの追加

新しいツールの設定を dotfiles で管理するには、対応する Stow パッケージディレクトリを作成します。

### 手順

以下の例では `starship` の設定を追加します。

```zsh
cd ~/dev/dotfiles

# 1. パッケージディレクトリをホームディレクトリと同じ構造で作成
mkdir -p starship/.config

# 2. 設定ファイルを配置（または既存ファイルを移動）
mv ~/.config/starship.toml starship/.config/starship.toml

# 3. シンボリックリンクを作成
stow --restow --target=$HOME --dir=~/dev/dotfiles starship

# 4. リンクが作成されたか確認
ls -la ~/.config/starship.toml
```

### Makefile への追加

`Makefile` と `bootstrap.sh` の `STOW_PACKAGES` に新しいパッケージ名を追加すると、
`make stow` および `bootstrap.sh` の実行時に自動で処理されます。

`Makefile` の該当行を編集します。

```makefile
# 変更前
STOW_PACKAGES := zsh git tmux nvim ghostty

# 変更後（starship を追加した例）
STOW_PACKAGES := zsh git tmux nvim ghostty bin ssh starship
```

`bootstrap.sh` の該当行も同様に編集します。

```zsh
# 変更前
STOW_PACKAGES=(zsh git tmux nvim ghostty)

# 変更後
STOW_PACKAGES=(zsh git tmux nvim ghostty bin ssh starship)
```

### Stow のディレクトリ構造ルール

Stow はパッケージディレクトリの中身を `--target`（デフォルトは `$HOME`）にそのまま展開します。

```
dotfiles/
└── starship/             # パッケージ名（任意）
    └── .config/
        └── starship.toml # -> ~/.config/starship.toml にリンク
```

ホームディレクトリ直下に置くファイルは、パッケージルートに置きます。

```
dotfiles/
└── zsh/
    ├── .zshrc            # -> ~/.zshrc にリンク
    └── .zprofile         # -> ~/.zprofile にリンク
```

---

## マシン固有の設定

### local.zsh

`~/.config/zsh/local.zsh` は Git 管理から除外されており、マシン固有の設定を書く場所です。
テンプレートをコピーして使います。

```zsh
cp ~/dev/dotfiles/zsh/.config/zsh/local.zsh.example \
   ~/dev/dotfiles/zsh/.config/zsh/local.zsh
```

> **注意:** `local.zsh` は `.gitignore` で除外されています。
> このファイルに書いた内容は Git にコミットされません。

`local.zsh` の記述例。

```zsh
# マシン固有の環境変数
export WORK_DIR="$HOME/work/my-project"

# マシン固有のエイリアス
alias work='cd $WORK_DIR'

# プロキシ設定（オフィス環境など）
export HTTP_PROXY="http://proxy.example.com:8080"
export HTTPS_PROXY="$HTTP_PROXY"
export NO_PROXY="localhost,127.0.0.1"

# Keychain からシークレットを取得して環境変数に展開
export GITHUB_TOKEN=$(security find-generic-password -s github-pat -a $USER -w 2>/dev/null || true)
export OPENAI_API_KEY=$(security find-generic-password -s openai-api-key -a $USER -w 2>/dev/null || true)
```

### .gitconfig.local

Git の個人設定（メールアドレスなど）をマシンごとに変えたい場合、
`~/.gitconfig.local` に書きます。このファイルは `~/.gitconfig` の末尾で自動で読み込まれます。

```zsh
# ~/.gitconfig.local の作成例
cat > ~/.gitconfig.local << 'EOF'
[user]
    name = macmariya
    email = work@example.com

[core]
    sshCommand = ssh -i ~/.ssh/id_work
EOF
```

---

## SSH 設定のカスタマイズ

### config.d/ によるホスト固有設定の追加

`~/.ssh/config.d/` ディレクトリはホスト固有の SSH 設定を置く場所です。
このディレクトリ内のファイルは Git 管理から除外されており、機密情報を安全に保管できます。

接続先ごとにファイルを分けて管理します。

```
# ~/.ssh/config.d/work.conf
Host work-server
    HostName server.example.com
    User deploy
    IdentityFile ~/.ssh/id_ed25519_work
    Port 22
```

### 複数の SSH 鍵の管理

用途ごとに鍵を生成して使い分けます。

```zsh
# 新しい鍵を生成する
ssh-keygen -t ed25519 -C "work@example.com" -f ~/.ssh/id_ed25519_work

# ssh-agent に追加する
ssh-add ~/.ssh/id_ed25519_work
```

### 踏み台サーバー（ProxyJump）の設定例

内部サーバーへ踏み台経由で接続する場合は `ProxyJump` を使います。

```
Host bastion
    HostName bastion.example.com
    User admin

Host internal
    HostName 10.0.1.100
    User deploy
    ProxyJump bastion
```

### パーミッションの修正

SSH 鍵ファイルのパーミッションがずれた場合は以下を実行します。

```zsh
make ssh-fix
```

---

## エイリアスの追加

### 共有エイリアス（全マシン共通）

`~/dev/dotfiles/zsh/.config/zsh/aliases.zsh` を編集します。
変更は Git にコミットされ、全マシンで共有されます。

```zsh
# aliases.zsh に追加する例
alias k='kubectl'
alias tf='terraform'
alias dc='docker compose'
```

### マシン固有のエイリアス

`~/.config/zsh/local.zsh` に追記します（Git にコミットされません）。

```zsh
# local.zsh に追加する例
alias vpn='sudo openconnect vpn.example.com'
alias devserver='ssh user@192.168.1.100'
```

### 変更の反映

エイリアスを追加後、シェルを再読み込みします。

```zsh
reload
# または
source ~/.zshrc
```

---

## Brewfile の管理

### 現在のパッケージを Brewfile に書き出す

Homebrew で手動インストールしたパッケージを Brewfile に反映します。

```zsh
make brew-dump
```

これは以下のコマンドを実行します。

```zsh
brew bundle dump --file=~/dev/dotfiles/Brewfile --force
```

### パッケージを手動で追加する

`~/dev/dotfiles/Brewfile` を直接編集して追加します。

```ruby
# CLI ツール
brew "ripgrep"

# GUI アプリ
cask "visual-studio-code"
cask "cursor"

# フォント
cask "font-fira-code-nerd-font"
```

変更後に Brewfile を適用します。

```zsh
make brew
```

### 定期的なアップデート

```zsh
# Homebrew パッケージを更新してシンボリックリンクを再作成
make update
```

これは `brew update && brew upgrade` と `make stow` を順に実行します。

---

## macOS 設定のカスタマイズ

`~/dev/dotfiles/macos.sh` を編集して自分好みの macOS 設定を追加します。

### 例: Dock に追加のカスタマイズを加える

```zsh
# macos.sh に追加する例

# Mission Control のアニメーション速度をさらに速くする
defaults write com.apple.dock expose-animation-duration -float 0.05

# Spaces を自動的に並べ替えない
defaults write com.apple.dock mru-spaces -bool false
```

設定を再適用するには以下を実行します。

```zsh
make macos
```

### デフォルト値の調べ方

現在の設定値は以下のコマンドで確認できます。

```zsh
# ドメイン内の全キーを確認
defaults read com.apple.dock

# 特定のキーを確認
defaults read com.apple.dock tilesize
```

---

## テーマの変更

### Oh My Zsh のテーマ変更

`~/dev/dotfiles/zsh/.zshrc` の `ZSH_THEME` を変更します。

```zsh
# 変更前
ZSH_THEME="agnoster"

# 変更後の例
ZSH_THEME="powerlevel10k/powerlevel10k"
```

利用可能なテーマは以下で確認できます。

```zsh
ls ~/.oh-my-zsh/themes/
```

### tmux のカラースキーム変更

`~/dev/dotfiles/tmux/.tmux.conf` のステータスバー設定を変更します。

```
# Catppuccin Mocha の bg カラー例（現在の設定）
set -g status-style "bg=#1e1e2e,fg=#cdd6f4"

# Dracula テーマに変更する例
set -g status-style "bg=#282a36,fg=#f8f8f2"
```

### Ghostty のテーマ変更

`~/dev/dotfiles/ghostty/.config/ghostty/config` の `theme` を変更します。

```
# 現在の設定
theme = catppuccin-mocha

# 別のテーマに変更する例
theme = dracula
```

利用可能なテーマ一覧は以下で確認できます。

```zsh
ghostty +list-themes
```

---

## 新しいシークレットの追加

### setup-secrets.sh への追加

`~/dev/dotfiles/secrets/setup-secrets.sh` にコメントアウトされたサンプルがあります。
必要なシークレットのブロックをコメント解除して追加します。

```zsh
# setup-secrets.sh に追加する例（OpenAI API Key）
printf "\033[1;33m--- OpenAI API Key ---\033[0m\n"
printf "OpenAI API Key を入力してください (非表示): "
read -rs OPENAI_KEY
printf "\n"

if [[ -n "$OPENAI_KEY" ]]; then
  _save_to_keychain "openai-api-key" "${USER}" "OpenAI API Key" "$OPENAI_KEY"
  success "OpenAI API Key を Keychain に登録しました"
fi
```

### 手動で Keychain に登録する

```zsh
security add-generic-password \
  -s "my-service-name" \
  -a "$USER" \
  -l "My Service Description" \
  -w "my-secret-value"
```

### Keychain からシークレットを取得する

```zsh
security find-generic-password -s "my-service-name" -a $USER -w
```

### bootstrap.sh のチェックに追加する

新しいシークレットを bootstrap.sh の Phase 7 チェックに追加することで、
セットアップ時に未登録を検知できます。

```zsh
# bootstrap.sh の Phase 7 に追加する例
_check_keychain "openai-api-key" "${USER}" "OpenAI API Key"
```

---

## Neovim のカスタマイズ

Neovim は lazy.nvim ベースのモジュラー構成で、プラグインごとにファイルが分離されている。

### ディレクトリ構造

```
nvim/.config/nvim/
├── init.lua                 # エントリポイント（4 モジュールを require）
├── lua/
│   ├── config/
│   │   ├── options.lua      # vim.opt 設定
│   │   ├── keymaps.lua      # キーマップ（Leader = Space）
│   │   ├── autocmds.lua     # 自動コマンド
│   │   └── lazy.lua         # lazy.nvim ブートストラップ
│   └── plugins/
│       ├── colorscheme.lua  # Catppuccin Mocha
│       ├── treesitter.lua   # 16 言語ハイライト
│       ├── lsp.lua          # Mason + lspconfig（8 サーバー）
│       ├── cmp.lua          # nvim-cmp 補完
│       ├── telescope.lua    # ファジーファインダー
│       ├── neo-tree.lua     # ファイルエクスプローラー
│       ├── lualine.lua      # ステータスライン
│       ├── gitsigns.lua     # Git 差分表示
│       ├── autopairs.lua    # 自動括弧閉じ
│       ├── comment.lua      # コメントトグル
│       ├── indent.lua       # インデントガイド
│       ├── which-key.lua    # キーバインドヘルプ
│       └── misc.lua         # devicons, illuminate, todo-comments
```

### プラグインの追加方法

`lua/plugins/` にファイルを追加すると lazy.nvim が自動で認識する。

```lua
-- lua/plugins/example.lua
return {
  "author/plugin-name",
  event = "VeryLazy",   -- 遅延読み込みトリガー
  opts = {
    -- プラグインオプション
  },
}
```

よく使う遅延読み込みトリガー:


| トリガー                                     | タイミング       |
| ---------------------------------------- | ----------- |
| `event = "VeryLazy"`                     | 起動完了後       |
| `event = { "BufReadPre", "BufNewFile" }` | ファイルを開いた時   |
| `event = "InsertEnter"`                  | インサートモード開始時 |
| `cmd = "CommandName"`                    | 特定コマンド実行時   |
| `keys = { "<leader>x" }`                 | 特定キー押下時     |
| `ft = "python"`                          | 特定ファイルタイプ時  |


### LSP サーバーの追加

`lua/plugins/lsp.lua` の `ensure_installed` に追加する。

```lua
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "ts_ls",
    "pyright",
    -- 追加するサーバー
    "gopls",       -- Go
    "rust_analyzer", -- Rust
  },
})
```

追加後に Neovim を再起動すると Mason が自動インストールする。手動の場合は `:MasonInstall gopls`。

### Treesitter パーサーの追加

`lua/plugins/treesitter.lua` の `ensure_installed` に追加する。

```lua
ensure_installed = {
  "lua", "vim", "vimdoc",
  -- 追加するパーサー
  "go", "rust", "toml",
},
```

### キーマップの追加

`lua/config/keymaps.lua` に追加する。

```lua
vim.keymap.set("n", "<leader>xx", "<cmd>SomeCommand<cr>", { desc = "説明" })
```

### テーマの変更

`lua/plugins/colorscheme.lua` を編集する。Catppuccin のフレーバーを変えるには:

```lua
require("catppuccin").setup({
  flavour = "latte",  -- latte, frappe, macchiato, mocha
})
```

別のテーマに切り替える場合は、ファイル全体を書き換える。

### プラグインの管理コマンド


| コマンド             | 説明                    |
| ---------------- | --------------------- |
| `:Lazy`          | プラグインマネージャ UI を開く     |
| `:Lazy update`   | 全プラグインを更新             |
| `:Lazy sync`     | インストール + 更新 + クリーンアップ |
| `:Mason`         | LSP サーバー管理 UI を開く     |
| `:TSInstallInfo` | Treesitter パーサー状態     |
| `:checkhealth`   | 全体の健全性チェック            |


### 参考リソース

- lazy.nvim: [https://github.com/folke/lazy.nvim](https://github.com/folke/lazy.nvim)
- nvim-lspconfig: [https://github.com/neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- Mason: [https://github.com/williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)
- Telescope: [https://github.com/nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- Catppuccin for Neovim: [https://github.com/catppuccin/nvim](https://github.com/catppuccin/nvim)

