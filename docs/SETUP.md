# 新しい Mac のセットアップ手順

このドキュメントは、新しい Mac に dotfiles 環境を構築する手順を説明します。

---

## 前提条件

- macOS（Apple Silicon / M シリーズチップ）
- インターネット接続
- Apple ID（App Store サインイン用）
- GitHub アカウント

> **注意:** Intel Mac では Homebrew のインストールパスが `/usr/local` になります。
> Apple Silicon では `/opt/homebrew` が使用されます。
> このリポジトリは Apple Silicon を想定して作成されています。

---

## Step 1: システム設定の初期確認

ターミナルを開いて、macOS のバージョンとチップを確認します。

```zsh
sw_vers
uname -m   # arm64 であれば Apple Silicon
```

macOS アップデートが残っている場合は先に適用します。

```zsh
softwareupdate --list
```

---

## Step 2: dotfiles リポジトリのクローン

開発用ディレクトリを作成してリポジトリをクローンします。

```zsh
mkdir -p ~/dev
git clone https://github.com/<your-username>/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
```

> **ヒント:** `git` コマンドを初めて実行すると、Xcode Command Line Tools のインストールダイアログが表示されることがあります。
> その場合は「インストール」をクリックして完了を待ってからリトライしてください。

---

## Step 3: bootstrap.sh の実行

`bootstrap.sh` はセットアップ全体を自動化するメインスクリプトです。
各フェーズが順番に実行され、既にインストール済みの場合はスキップされます（冪等性を保証）。

```zsh
cd ~/dev/dotfiles
zsh bootstrap.sh
```

または Makefile 経由で実行できます。

```zsh
make install
```

### 各フェーズの説明

| フェーズ | 内容 |
|---------|------|
| Phase 1 | Xcode Command Line Tools のインストール |
| Phase 2 | Homebrew のインストール（Apple Silicon: `/opt/homebrew`） |
| Phase 3 | `Brewfile` からパッケージを一括インストール |
| Phase 4 | Oh My Zsh のインストール |
| Phase 5 | Oh My Zsh カスタムプラグイン（syntax-highlighting, autosuggestions） |
| Phase 6 | GNU Stow でシンボリックリンクを作成。既存設定の自動救出・競合解決・tree folding 防止付き |
| Phase 7 | SSH パーミッション修正 & Ed25519 鍵生成（対話式） |
| Phase 8 | macOS Keychain にシークレットが登録済みかチェック |
| Phase 9 | macOS システム設定の適用（対話形式で確認あり） |
| Phase 10 | Claude Code のインストール（スタンドアロンインストーラー） |

Phase 7 では以下の処理が自動的に行われます。

- `~/.ssh` ディレクトリのパーミッションを 700 に修正
- `~/.ssh/config` ファイルのパーミッションを 600 に修正
- Ed25519 鍵が存在しない場合、鍵の生成を提案
- 公開鍵を GitHub に登録する方法を案内

Phase 9 では以下のプロンプトが表示されます。

```
macOS のシステム設定を適用しますか？ (y/N):
```

`y` を入力すると `macos.sh` が実行されます。後から適用する場合は `N` でスキップして、`make macos` で後から実行できます。

---

## Step 4: シークレットの設定

`bootstrap.sh` 完了後、GitHub PAT などのシークレットを macOS Keychain に登録します。

```zsh
zsh ~/dev/dotfiles/secrets/setup-secrets.sh
```

### macOS Keychain への登録手順

スクリプトを実行すると、対話形式でシークレットの入力を求められます。
入力値は画面に表示されません（非表示入力）。

```
--- GitHub Personal Access Token (PAT) ---
GitHub PAT を入力してください (非表示):
```

PAT を貼り付けて Enter を押すと、Keychain に安全に保存されます。

### 登録の確認

```zsh
security find-generic-password -s github-pat -a $USER -w
```

先頭4文字が表示されれば登録成功です。

### GitHub PAT の取得方法

1. <https://github.com/settings/tokens> にアクセス
2. 「Generate new token (classic)」をクリック
3. 必要なスコープを選択: `repo`, `read:org`, `workflow`
4. 「Generate token」をクリックしてコピー

> **重要:** PAT はページを離れると再表示できません。必ずコピーしてから `setup-secrets.sh` を実行してください。

### zsh から Keychain のシークレットを使う

`~/.config/zsh/local.zsh` に以下を追加すると、シェル起動時に自動で環境変数に展開されます。

```zsh
export GITHUB_TOKEN=$(security find-generic-password -s github-pat -a $USER -w)
```

---

## Step 4.5: SSH 鍵の設定

`bootstrap.sh` の Phase 7 が SSH ディレクトリのパーミッション修正と鍵生成を自動的に処理します。
手動で設定したい場合や確認が必要な場合は以下の手順を参照してください。

### Ed25519 鍵の生成

```zsh
ssh-keygen -t ed25519 -C "your@email.com"
```

プロンプトに従って保存先（デフォルト: `~/.ssh/id_ed25519`）とパスフレーズを設定します。

### 公開鍵のコピー

```zsh
cat ~/.ssh/id_ed25519.pub | pbcopy
```

クリップボードに公開鍵がコピーされます。

### GitHub への登録

1. <https://github.com/settings/keys> にアクセス
2. 「New SSH key」をクリック
3. タイトルを入力（例: `MacBook Pro M5`）
4. 「Key」欄にクリップボードの内容を貼り付け
5. 「Add SSH key」をクリック

### 接続テスト

```zsh
ssh -T git@github.com
```

`Hi <username>! You've successfully authenticated` と表示されれば成功です。

### ホスト固有の設定

ホストごとの SSH 設定は `~/.ssh/config.d/` ディレクトリに個別ファイルとして追加できます。
Stow によって作成された `~/.ssh/config` が `Include ~/.ssh/config.d/*` で自動的に読み込みます。

```zsh
# 例: ~/.ssh/config.d/work
Host work-server
  HostName 192.168.1.100
  User deploy
  IdentityFile ~/.ssh/id_ed25519_work
```

---

## Step 5: macOS 設定の適用

bootstrap.sh でスキップした場合や設定を再適用したい場合は以下を実行します。

```zsh
make macos
```

または直接実行できます。

```zsh
zsh ~/dev/dotfiles/macos.sh
```

このスクリプトは以下の設定を適用します。

- **一般:** ダークモード、自動アップデート
- **キーボード:** キーリピート高速化、自動修正・大文字変換の無効化
- **Finder:** 隠しファイル表示、拡張子表示、パスバー表示
- **Dock:** 自動非表示、即時表示、アイコンサイズ 48px
- **スクリーンショット:** 保存先 `~/Documents/Screenshots`、影なし
- **トラックパッド:** タップでクリック、追跡速度調整
- **セキュリティ:** スクリーンセーバー後即パスワード要求、ファイアウォール有効化

> **注意:** 一部の設定（ダークモード、キーボード設定）は再ログインまたは再起動後に有効になります。

---

## Step 6: 追加フォントのインストール

Ghostty のフォント設定で HackGen Console NF を使用しています。
Brewfile に含まれているため `bootstrap.sh` で自動インストールされますが、
手動でインストールする場合は以下を実行します。

```zsh
brew install --cask font-hackgen-console-nerd-font
brew install --cask font-udev-gothic-nf
```

インストール後、フォントがシステムに認識されているか確認します。

```zsh
fc-list | grep -i hackgen
```

---

## Step 7: Ghostty の設定確認

Ghostty は Brewfile 経由でインストールされます。

```zsh
brew install --cask ghostty
```

設定ファイルは Stow によって以下にシンボリックリンクが作成されています。

```
~/.config/ghostty/config → ~/dev/dotfiles/ghostty/.config/ghostty/config
```

Ghostty を起動して以下を確認します。

- フォント: HackGen Console NF、サイズ 14pt
- テーマ: Catppuccin Mocha
- シェル統合: zsh（プロンプトの検知・コマンド追跡が有効）

設定ファイルを変更した後は `Cmd + Shift + ,` でリロードできます。

利用可能なテーマ一覧を確認するには、ターミナルで以下を実行します。

```zsh
ghostty +list-themes
```

---

## Step 8: Neovim プラグインのインストール

Stow によって `~/.config/nvim` にシンボリックリンクが作成されています。

```
~/.config/nvim/ → ~/dev/dotfiles/nvim/.config/nvim/
```

初回起動時に lazy.nvim が自動的にブートストラップされ、全 29 プラグインがインストールされます。

```zsh
nvim
```

初回起動後の確認事項:

1. lazy.nvim のインストール画面が表示される → 完了まで待機
2. Mason が LSP サーバーを自動インストールする → `:Mason` で進捗確認
3. Treesitter がパーサーをダウンロードする → `:TSInstallInfo` で状態確認

### Mason で管理される LSP サーバー

| サーバー | 言語 |
|---------|------|
| `lua_ls` | Lua（Neovim 設定用） |
| `ts_ls` | TypeScript / JavaScript |
| `pyright` | Python |
| `bashls` | Bash |
| `jsonls` | JSON |
| `yamlls` | YAML |
| `html` | HTML |
| `cssls` | CSS |

### 動作確認

```zsh
# lazy.nvim のステータス確認
nvim -c ':Lazy'

# Mason のインストール状態確認
nvim -c ':Mason'

# Treesitter のインストール確認
nvim -c ':TSInstallInfo'
```

> **ヒント:** `:checkhealth` コマンドで全体の健全性チェックができます。

---

## Step 9: Claude Code の認証

Claude Code は `bootstrap.sh` の Phase 10 で自動インストールされます。
初回利用時にサブスクリプション認証が必要です。

```zsh
claude
```

ブラウザが開き、Claude Pro / Max サブスクリプションでの認証画面が表示されます。
認証完了後、ターミナルに戻ると Claude Code が使用可能になります。

### 動作確認

```zsh
claude --version
```

> **ヒント:** 手動でインストールする場合は `curl -fsSL https://claude.ai/install.sh | sh` を実行してください。

---

## Step 10: シェルの再起動と動作確認

全設定が完了したらシェルを再起動します。

```zsh
exec zsh
```

以下を確認して正常に動作しているか検証します。

```zsh
# zsh プラグインが読み込まれているか
echo $ZSH_THEME             # agnoster

# エイリアスが有効か
dots                        # ~/dev/dotfiles に移動する
reload                      # .zshrc を再読み込みする

# シンボリックリンクが正しく作成されているか
ls -la ~/.zshrc             # -> ~/dev/dotfiles/zsh/.zshrc
ls -la ~/.gitconfig         # -> ~/dev/dotfiles/git/.gitconfig
ls -la ~/.tmux.conf         # -> ~/dev/dotfiles/tmux/.tmux.conf
ls -la ~/.config/nvim/      # ディレクトリ内の各ファイルが個別にリンク
ls -la ~/.ssh/config        # -> ~/dev/dotfiles/ssh/.ssh/config

# Neovim プラグインがインストールされているか
ls ~/.local/share/nvim/lazy/ | wc -l  # 29 と表示されれば OK

# Homebrew が正常に動作するか
brew doctor
```

---

## トラブルシューティング

### Stow の競合エラー

`make stow` と `bootstrap.sh` は既存ファイルとの競合を自動解決します。
競合が検出されると以下の処理が行われます。

1. `stow --adopt` で既存ファイルをリポジトリに取り込みシンボリックリンクに置換
2. `git checkout` でリポジトリ側のファイルを正しい内容に復元
3. `stow --restow` でリンクを最終確定

`bootstrap.sh` ではさらに、stow 前に既存の `.zshrc` の内容を `~/.config/zsh/local.zsh` に救出し、
元のファイルを `.stow-backup/` にタイムスタンプ付きでバックアップします。

手動で競合を確認したい場合:

```zsh
# 競合をシミュレーション（実際の変更なし）
stow --simulate --restow --target=$HOME --dir=~/dev/dotfiles zsh

# バックアップを確認
ls .stow-backup/
```

壊れたシンボリックリンクの確認と整理には `make clean` が使えます。

```zsh
make clean
```

---

### Oh My Zsh プラグインが見つからない

`zsh-syntax-highlighting` または `zsh-autosuggestions` が見つからないエラーが出る場合。

```zsh
# Oh My Zsh のカスタムプラグインを確認
ls ~/.oh-my-zsh/custom/plugins/

# 手動でインストール
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
  ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
```

---

### Keychain のアクセス権限エラー

シークレットの取得時に権限エラーが出る場合、Keychain Access アプリで確認します。

1. Spotlight で「キーチェーンアクセス」を検索して開く
2. 「github-pat」を検索
3. 対象エントリをダブルクリック
4. 「アクセスコントロール」タブで許可するアプリを確認

コマンドラインから許可を付与する場合。

```zsh
security find-generic-password -s github-pat -a $USER -w
# ダイアログが表示されたら「常に許可」をクリック
```

---

### Neovim のプラグインが動作しない

lazy.nvim やプラグインの問題を調査するには `:checkhealth` が便利です。

```zsh
nvim -c ':checkhealth'
```

**lazy.nvim 自体が起動しない場合:**

```zsh
# lazy.nvim のデータを完全にリセット
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy

# Neovim を再起動（自動で再インストールされる）
nvim
```

**Mason の LSP サーバーが動作しない場合:**

```zsh
# Mason でインストール済みサーバーを確認
nvim -c ':Mason'

# 特定のサーバーを手動で再インストール
nvim -c ':MasonInstall pyright'
```

**Treesitter のパーサーエラー:**

```zsh
# パーサーを再ビルド
nvim -c ':TSUpdate'
```

---

### Ghostty でフォントが表示されない

HackGen Console NF がシステムに認識されていない場合。

```zsh
# フォントキャッシュを更新
fc-cache -fv

# フォントの存在確認
fc-list | grep -i hackgen

# 再インストール
brew reinstall --cask font-hackgen-console-nerd-font
```

それでも表示されない場合は、Ghostty の設定ファイルでフォールバックフォントを試します。

```
# ~/.config/ghostty/config
font-family = JetBrainsMono Nerd Font
```

---

### SSH の接続エラー

**Permission denied (publickey) が表示される場合:**

SSH ディレクトリやファイルのパーミッションが正しくない可能性があります。

```zsh
make ssh-fix
```

このコマンドで `~/.ssh` を 700、`~/.ssh/config` を 600 に修正します。

**SSH エージェントが鍵を転送しない場合:**

`~/.ssh/config` に以下の設定が含まれているか確認します。

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
```

設定を追加した後、エージェントに鍵を再登録します。

```zsh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

---

## 参照

| リソース | URL |
|---------|-----|
| Homebrew | <https://brew.sh> |
| Oh My Zsh | <https://ohmyz.sh> |
| GNU Stow | <https://www.gnu.org/software/stow/> |
| Ghostty | <https://ghostty.org> |
| HackGen フォント | <https://github.com/yuru7/HackGen> |
| lazy.nvim | <https://github.com/folke/lazy.nvim> |
| Mason | <https://github.com/williamboman/mason.nvim> |
| GitHub PAT | <https://github.com/settings/tokens> |
