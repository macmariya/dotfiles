-- ==========================================================
-- 自動コマンド設定
-- ==========================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── ヤンク時にハイライト ────────────────────────────────
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  desc = "ヤンクした範囲を一瞬ハイライトする",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- ── 最後のカーソル位置を復元 ────────────────────────────
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  desc = "ファイルを開いた時に前回のカーソル位置に移動する",
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── ターミナルモードで行番号を非表示 ────────────────────
augroup("TerminalSettings", { clear = true })
autocmd("TermOpen", {
  group = "TerminalSettings",
  desc = "ターミナルバッファで行番号を非表示にする",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- ── 特定ファイルタイプで q で閉じる ─────────────────────
augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
  group = "CloseWithQ",
  desc = "ヘルプやQFなどのバッファを q で閉じられるようにする",
  pattern = {
    "help",
    "man",
    "qf",
    "lspinfo",
    "notify",
    "checkhealth",
    "spectre_panel",
    "startuptime",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", {
      buffer = event.buf,
      silent = true,
      desc = "バッファを閉じる",
    })
  end,
})

-- ── ファイル変更の自動検知 ──────────────────────────────
augroup("AutoReload", { clear = true })
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = "AutoReload",
  desc = "外部でファイルが変更された場合に自動で再読み込みする",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- ── 保存時に末尾空白を削除 ──────────────────────────────
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  desc = "保存時にファイル末尾の余分な空白行と各行末の空白を削除する",
  callback = function()
    -- 末尾空白が意味を持つファイルタイプは除外
    local exclude_ft = { "markdown", "diff" }
    if vim.tbl_contains(exclude_ft, vim.bo.filetype) then
      return
    end
    local save_cursor = vim.fn.getpos(".")
    -- 各行末の空白を削除
    vim.cmd([[%s/\s\+$//e]])
    -- カーソル位置を復元
    vim.fn.setpos(".", save_cursor)
  end,
})
