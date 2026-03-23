-- ==========================================================
-- その他の小さなプラグイン
-- ==========================================================

return {
  -- ── nvim-web-devicons: ファイルタイプアイコン ─────────
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true, -- 他のプラグインの依存関係として遅延読み込み
    opts = {
      default = true, -- デフォルトアイコンを有効化
    },
  },

  -- ── vim-illuminate: 同じ単語のハイライト ──────────────
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200, -- ハイライトまでの遅延(ms)
      -- 大きなファイルでは無効化
      large_file_cutoff = 2000,
      -- 無効にするファイルタイプ
      filetypes_denylist = {
        "neo-tree",
        "lazy",
        "mason",
        "help",
        "TelescopePrompt",
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      -- ハイライトグループの色をカスタマイズ（カラースキーム変更時にも維持）
      local function set_illuminate_hl()
        vim.api.nvim_set_hl(0, "IlluminatedWordText", { underline = true })
        vim.api.nvim_set_hl(0, "IlluminatedWordRead", { underline = true })
        vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { underline = true })
      end
      set_illuminate_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_illuminate_hl })
    end,
  },

  -- ── todo-comments.nvim: TODO/FIXME/NOTE ハイライト ────
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    -- keys はキーバインド登録用（event でハイライト用に早期ロード済み）
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "次の TODO コメントへ" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "前の TODO コメントへ" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "TODO 一覧 (Telescope)" },
    },
    opts = {
      signs = true, -- サインカラムにアイコンを表示
      -- キーワード設定
      keywords = {
        FIX = {
          icon = " ",
          color = "error",
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },
}
