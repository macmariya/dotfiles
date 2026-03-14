-- ==========================================================
-- Lualine ステータスライン
-- ==========================================================

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    options = {
      theme = "catppuccin",           -- Catppuccin テーマと連携
      globalstatus = true,             -- グローバルステータスライン
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = { "neo-tree" },   -- Neo-tree ではステータスラインを非表示
      },
    },
    sections = {
      -- 左セクション
      lualine_a = { "mode" },          -- 現在のモード
      lualine_b = {
        "branch",                      -- Git ブランチ
        {
          "diff",                      -- Git 差分
          symbols = {
            added = " ",
            modified = " ",
            removed = " ",
          },
        },
        {
          "diagnostics",               -- LSP 診断情報
          symbols = {
            error = " ",
            warn = " ",
            hint = "󰌵 ",
            info = " ",
          },
        },
      },
      lualine_c = {
        {
          "filename",                  -- ファイル名
          path = 1,                    -- 相対パスで表示
          symbols = {
            modified = " ●",          -- 変更あり
            readonly = " ",           -- 読み取り専用
            unnamed = " [No Name]",
          },
        },
      },
      -- 右セクション
      lualine_x = {
        "encoding",                    -- エンコーディング
        {
          "fileformat",                -- ファイルフォーマット (unix/dos/mac)
          symbols = {
            unix = " LF",
            dos = " CRLF",
            mac = " CR",
          },
        },
        "filetype",                    -- ファイルタイプ
      },
      lualine_y = { "progress" },      -- 進捗率
      lualine_z = { "location" },      -- カーソル位置 (行:列)
    },
    -- 非アクティブウィンドウのセクション
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    extensions = { "neo-tree", "lazy" },
  },
}
