-- ==========================================================
-- Comment.nvim コメントトグル
-- ==========================================================

return {
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
  opts = {
    -- gcc: 行コメントトグル（デフォルト）
    -- gbc: ブロックコメントトグル（デフォルト）
    -- gc: ビジュアルモードでコメントトグル（デフォルト）

    -- Treesitter と連携してコメント文字列を自動判定
    pre_hook = nil, -- ts-context-commentstring を使う場合はここで設定
  },
}
