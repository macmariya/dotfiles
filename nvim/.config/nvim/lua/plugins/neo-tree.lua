-- ==========================================================
-- Neo-tree ファイルエクスプローラー
-- ==========================================================

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "ファイルエクスプローラー" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- 閉じる時に Neo-tree のバッファをクリーンアップ
    close_if_last_window = true,
    -- ポップアップの入力ボーダー
    popup_border_style = "rounded",
    -- ファイルシステム設定
    filesystem = {
      -- 隠しファイルを表示
      filtered_items = {
        visible = true,       -- フィルタされたアイテムを薄く表示
        hide_dotfiles = false, -- ドットファイルを表示
        hide_gitignored = false, -- .gitignore のファイルも表示
        hide_by_name = {
          ".DS_Store",
          "thumbs.db",
        },
      },
      -- カレントディレクトリの自動追従
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      -- netrw の代替として使用
      hijack_netrw_behavior = "open_default",
      -- ファイルシステムの監視
      use_libuv_file_watcher = true,
    },
    -- ウィンドウ設定
    window = {
      position = "left",
      width = 35,
      mappings = {
        ["<space>"] = "none", -- leader キーとの衝突を回避
        ["l"] = "open",       -- l でファイルを開く
        ["h"] = "close_node", -- h でノードを閉じる
      },
    },
    -- Git ステータス表示
    git_status = {
      symbols = {
        added = "✚",
        modified = "",
        deleted = "✖",
        renamed = "󰁕",
        untracked = "",
        ignored = "",
        unstaged = "󰄱",
        staged = "",
        conflict = "",
      },
    },
    -- デフォルトのコンポーネントを設定
    default_component_configs = {
      indent = {
        with_expanders = true, -- 展開・折りたたみアイコンを表示
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "󰜌",
      },
    },
  },
}
