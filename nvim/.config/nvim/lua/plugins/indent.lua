-- ==========================================================
-- indent-blankline.nvim インデントガイド (v3)
-- ==========================================================

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl", -- v3 では "ibl" モジュールを使用
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    indent = {
      char = "│",               -- インデントガイドの文字
      tab_char = "│",           -- タブ文字のインデントガイド
    },
    scope = {
      enabled = true,           -- 現在のスコープをハイライト
      show_start = true,        -- スコープの開始行をハイライト
      show_end = false,         -- スコープの終了行はハイライトしない
    },
    exclude = {
      filetypes = {
        "help",
        "neo-tree",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
    },
  },
}
