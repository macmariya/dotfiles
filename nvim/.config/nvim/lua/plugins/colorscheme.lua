-- ==========================================================
-- Catppuccin カラースキーム
-- ==========================================================

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- 最優先で読み込む
  lazy = false,
  opts = {
    flavour = "mocha", -- Mocha フレーバー（ダーク系）
    transparent_background = false, -- 透過背景はオフ
    term_colors = true, -- ターミナルカラーを設定
    dim_inactive = {
      enabled = false, -- 非アクティブウィンドウを暗くしない
    },
    styles = {
      comments = { "italic" },    -- コメントをイタリック
      conditionals = { "italic" }, -- 条件文をイタリック
    },
    -- 各プラグインとの統合設定
    integrations = {
      cmp = true,
      gitsigns = true,
      treesitter = true,
      telescope = { enabled = true },
      indent_blankline = { enabled = true },
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      neotree = true,
      which_key = true,
      illuminate = {
        enabled = true,
        lsp = false,
      },
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
