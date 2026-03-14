-- ==========================================================
-- lazy.nvim ブートストラップ & プラグイン読み込み
-- ==========================================================

-- lazy.nvim の自動インストール
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "lazy.nvim のクローンに失敗しました:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

-- plugins/ ディレクトリ内の全プラグイン設定を自動読み込み
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  -- lazy.nvim 自体の設定
  defaults = {
    lazy = true, -- デフォルトで遅延読み込み（必要なものだけ lazy = false を個別指定）
  },
  install = {
    colorscheme = { "catppuccin" }, -- インストール中に使用するカラースキーム
  },
  checker = {
    enabled = true, -- プラグインの更新を自動チェック
    notify = false, -- 更新通知を表示しない
  },
  change_detection = {
    notify = false, -- 設定変更時の通知を表示しない
  },
  ui = {
    border = "rounded", -- UI のボーダースタイル
    icons = {
      cmd = " ",
      config = "",
      event = " ",
      ft = " ",
      init = " ",
      import = " ",
      keys = " ",
      lazy = "󰒲 ",
      loaded = "●",
      not_loaded = "○",
      plugin = " ",
      runtime = " ",
      require = "󰢱 ",
      source = " ",
      start = " ",
      task = "✔ ",
      list = { "●", "➜", "★", "‒" },
    },
  },
  performance = {
    rtp = {
      -- 不要な組み込みプラグインを無効化して起動を高速化
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
