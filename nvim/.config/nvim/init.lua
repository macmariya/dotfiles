-- ==========================================================
-- Neovim v0.11.6 設定エントリポイント
-- ==========================================================

-- 基本設定の読み込み
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- プラグインマネージャ (lazy.nvim) の初期化
require("config.lazy")
