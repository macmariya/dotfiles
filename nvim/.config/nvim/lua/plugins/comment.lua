-- ==========================================================
-- Comment.nvim コメントトグル
-- ==========================================================

return {
  -- NOTE: Neovim 0.10+ は gc/gb をビルトイン対応。
  -- <leader>/ のカスタムバインドが不要になれば本プラグインは削除可。
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    -- <leader>/ でコメントトグル（ノーマル & ビジュアル）
    {
      "<leader>/",
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      desc = "コメントトグル（行）",
      mode = "n",
    },
    {
      "<leader>/",
      "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
      desc = "コメントトグル（選択範囲）",
      mode = "v",
    },
  },
  opts = {},
}
