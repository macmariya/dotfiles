-- ==========================================================
-- Telescope ファジーファインダー
-- ==========================================================

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- fzf ネイティブ拡張（高速ソート）
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    -- ファイル検索
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "ファイル検索" },
    -- ライブ grep（ripgrep 使用）
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "テキスト検索 (grep)" },
    -- バッファ一覧
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "バッファ一覧" },
    -- ヘルプタグ
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "ヘルプタグ検索" },
    -- 最近開いたファイル
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近のファイル" },
    -- 診断一覧
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "診断一覧" },
    -- Git ファイル
    { "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Git ファイル検索" },
    -- 現在のバッファ内検索
    { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "バッファ内検索" },
  },
  opts = {
    defaults = {
      -- プロンプトのプレフィックス
      prompt_prefix = "   ",
      selection_caret = "  ",
      entry_prefix = "  ",
      -- レイアウト設定
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
        },
        width = 0.87,
        height = 0.80,
      },
      sorting_strategy = "ascending",
      -- ファイル無視パターン
      file_ignore_patterns = {
        "node_modules",
        ".git/",
        "dist/",
        "build/",
        "%.lock",
        "__pycache__",
        "%.pyc",
      },
      -- ボーダー設定
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      -- マッピング
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
          ["<C-q>"] = "send_to_qflist",
          ["<Esc>"] = "close",
        },
      },
    },
    pickers = {
      find_files = {
        hidden = true, -- 隠しファイルも検索対象に含める
      },
    },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)

    -- fzf 拡張の読み込み（ビルド済みの場合）
    pcall(telescope.load_extension, "fzf")
  end,
}
