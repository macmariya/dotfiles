-- ==========================================================
-- Treesitter シンタックスハイライト & テキストオブジェクト
-- ==========================================================

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" }, -- ファイル読み込み時に遅延読み込み
  cmd = { "TSInstall", "TSUpdate", "TSBufEnable", "TSBufDisable" },
  opts = {
    -- 自動インストールする言語パーサー
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "javascript",
      "typescript",
      "tsx",
      "python",
      "json",
      "yaml",
      "html",
      "css",
      "bash",
      "markdown",
      "markdown_inline",
      "go",
      "rust",
    },
    auto_install = true, -- 未インストールのパーサーを自動インストール
    highlight = {
      enable = true, -- シンタックスハイライトを有効化
      additional_vim_regex_highlighting = false, -- Vim 正規表現ハイライトは無効
    },
    indent = {
      enable = true, -- Treesitter ベースのインデントを有効化
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",    -- 選択開始
        node_incremental = "<C-space>",  -- ノード単位で選択拡大
        scope_incremental = false,       -- スコープ拡大は無効
        node_decremental = "<bs>",       -- ノード単位で選択縮小
      },
    },
  }
}
