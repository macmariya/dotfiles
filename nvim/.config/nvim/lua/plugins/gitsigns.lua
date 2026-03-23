-- ==========================================================
-- Gitsigns Git 差分表示
-- ==========================================================

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- サインカラムに表示するシンボル
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "━" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    -- ステージ済み hunk のシンボル（gitsigns 0.9+）
    signs_staged = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "━" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    -- 行単位の blame 表示（デフォルトはオフ、必要に応じて有効化）
    current_line_blame = false,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 500,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    -- キーマップ設定
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local map = function(mode, l, r, desc, opts)
        opts = vim.tbl_extend("force", { buffer = bufnr, desc = desc }, opts or {})
        vim.keymap.set(mode, l, r, opts)
      end

      -- Hunk 移動（expr = true で diff モードのフォールバックを有効化）
      map("n", "]h", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, "次の hunk へ", { expr = true })

      map("n", "[h", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, "前の hunk へ", { expr = true })

      -- Hunk 操作
      map("n", "<leader>hs", gs.stage_hunk, "Hunk をステージ")
      map("n", "<leader>hr", gs.reset_hunk, "Hunk をリセット")
      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "選択 hunk をステージ")
      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "選択 hunk をリセット")

      -- バッファ全体の操作
      map("n", "<leader>hS", gs.stage_buffer, "バッファ全体をステージ")
      map("n", "<leader>hR", gs.reset_buffer, "バッファ全体をリセット")

      -- Hunk のプレビュー・差分表示
      map("n", "<leader>hp", gs.preview_hunk, "Hunk をプレビュー")
      map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, "行の blame を表示")
      map("n", "<leader>hd", gs.diffthis, "差分を表示")

      -- blame 表示のトグル
      map("n", "<leader>tb", gs.toggle_current_line_blame, "行 blame をトグル")
    end,
  },
}
