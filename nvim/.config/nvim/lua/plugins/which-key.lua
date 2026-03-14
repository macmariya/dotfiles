-- ==========================================================
-- which-key.nvim キーバインドヘルプ
-- ==========================================================

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- ポップアップウィンドウの設定
    win = {
      border = "rounded",
    },
    -- アイコン設定
    icons = {
      breadcrumb = ">>",
      separator = "->",
      group = "+ ",
    },
    -- レイアウト
    layout = {
      spacing = 3,
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Leader キーのグループ名を登録
    wk.add({
      { "<leader>c", group = "コード" },
      { "<leader>f", group = "検索 (Telescope)" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Git hunk" },
      { "<leader>r", group = "リネーム" },
      { "<leader>t", group = "トグル" },
    })
  end,
}
