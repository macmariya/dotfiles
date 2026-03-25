-- ==========================================================
-- Neovim 基本オプション設定
-- ==========================================================

local opt = vim.opt

-- ── 行番号 ──────────────────────────────────────────────
opt.number = true         -- 行番号を表示
opt.relativenumber = true -- 相対行番号を表示
opt.cursorline = true     -- カーソル行をハイライト

-- ── スクロール ──────────────────────────────────────────
opt.scrolloff = 8         -- 上下8行の余白を確保
opt.sidescrolloff = 8     -- 左右8列の余白を確保

-- ── インデント ──────────────────────────────────────────
opt.tabstop = 2           -- タブ文字の表示幅
opt.shiftwidth = 2        -- 自動インデントの幅
opt.softtabstop = 2       -- タブキー押下時の移動幅
opt.expandtab = true      -- タブをスペースに展開
opt.smartindent = true    -- スマートインデント有効

-- ── 検索 ────────────────────────────────────────────────
opt.ignorecase = true     -- 検索時に大文字小文字を無視
opt.smartcase = true      -- 大文字を含む場合は区別する
opt.hlsearch = true       -- 検索結果をハイライト
opt.incsearch = true      -- インクリメンタルサーチ

-- ── ウィンドウ分割 ──────────────────────────────────────
opt.splitbelow = true     -- 水平分割は下に開く
opt.splitright = true     -- 垂直分割は右に開く

-- ── クリップボード ──────────────────────────────────────
opt.clipboard = "unnamedplus" -- システムクリップボードと連携

-- ── ファイル管理 ────────────────────────────────────────
opt.undofile = true       -- アンドゥ履歴をファイルに保存
opt.swapfile = false      -- スワップファイルを無効化
opt.backup = false        -- バックアップファイルを無効化
opt.writebackup = false   -- 書き込み時のバックアップを無効化

-- ── 表示 ────────────────────────────────────────────────
opt.termguicolors = true  -- True Color サポート有効
opt.signcolumn = "yes"    -- サインカラムを常に表示
opt.wrap = false          -- 行の折り返しを無効化
opt.showmode = false      -- モード表示をオフ（lualineで表示）
opt.pumheight = 10        -- ポップアップメニューの最大高さ
opt.conceallevel = 0      -- テキストの隠蔽レベル

-- ── 日本語対応 ──────────────────────────────────────────
-- Neovim は内部エンコーディングが常に UTF-8 のため opt.encoding は不要
opt.fileencoding = "utf-8"                      -- ファイル保存時のエンコーディング
opt.fileencodings = "utf-8,euc-jp,cp932"        -- ファイル読み込み時の自動判定順序

-- ── パフォーマンス ──────────────────────────────────────
opt.updatetime = 250      -- CursorHold イベントの発火間隔(ms)
opt.timeoutlen = 300      -- キーマップのタイムアウト(ms)
opt.lazyredraw = false    -- マクロ実行中の再描画（falseでlazy.nvim互換）

-- ── 補完 ────────────────────────────────────────────────
opt.completeopt = "menu,menuone,noselect" -- 補完メニューの動作設定

-- ── その他 ──────────────────────────────────────────────
opt.mouse = "a"           -- 全モードでマウスを有効化
opt.fillchars = { eob = " " } -- バッファ末尾の ~ を消す
