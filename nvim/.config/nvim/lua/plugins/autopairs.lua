-- ==========================================================
-- Autopairs 自動括弧閉じ
-- ==========================================================

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/nvim-cmp",
    "nvim-treesitter/nvim-treesitter", -- check_ts = true に必要
  },
  config = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({
      check_ts = true, -- Treesitter による文脈判断を有効化
      ts_config = {
        lua = { "string" },        -- Lua の文字列内では無効
        javascript = { "template_string" }, -- JS のテンプレートリテラル内では無効
      },
      fast_wrap = {
        map = "<M-e>", -- Alt+e で素早く括弧で囲む
      },
    })

    -- nvim-cmp との統合: 補完確定時に括弧を自動追加
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp = require("cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
}
