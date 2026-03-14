-- ==========================================================
-- LSP 設定 (Mason + nvim-lspconfig)
-- ==========================================================

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- LSP サーバー自動インストール
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      -- LSP 補完ソース（cmp との連携）
      { "hrsh7th/cmp-nvim-lsp" },
    },
    config = function()
      -- ── 診断の表示設定（Neovim 0.10+ 対応）────────────
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●", -- 仮想テキストのプレフィックス
          spacing = 4,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰌵 ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
        underline = true,
        update_in_insert = false, -- インサートモード中は診断を更新しない
        severity_sort = true,     -- 重要度順でソート
        float = {
          border = "rounded",
          source = true,
          header = "",
          prefix = "",
        },
      })

      -- ── LSP アタッチ時のキーマップ設定 ────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
        desc = "LSP キーマップを設定する",
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, {
              buffer = event.buf,
              desc = "LSP: " .. desc,
            })
          end

          -- 定義・参照ジャンプ
          map("gd", vim.lsp.buf.definition, "定義へ移動")
          map("gD", vim.lsp.buf.declaration, "宣言へ移動")
          map("gr", vim.lsp.buf.references, "参照一覧")
          map("gI", vim.lsp.buf.implementation, "実装へ移動")
          map("gy", vim.lsp.buf.type_definition, "型定義へ移動")

          -- 情報表示
          map("K", vim.lsp.buf.hover, "ホバー情報")
          map("<C-k>", vim.lsp.buf.signature_help, "シグネチャヘルプ", "i")

          -- コードアクション
          map("<leader>ca", vim.lsp.buf.code_action, "コードアクション", { "n", "v" })
          map("<leader>rn", vim.lsp.buf.rename, "リネーム")

          -- 診断
          map("[d", vim.diagnostic.goto_prev, "前の診断へ")
          map("]d", vim.diagnostic.goto_next, "次の診断へ")
          map("<leader>cd", vim.diagnostic.open_float, "診断の詳細表示")

          -- フォーマット
          map("<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "フォーマット")
        end,
      })

      -- ── LSP サーバーの capabilities 設定 ──────────────
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- nvim-cmp との連携で補完候補を拡張
      local cmp_lsp = require("cmp_nvim_lsp")
      capabilities = vim.tbl_deep_extend(
        "force",
        capabilities,
        cmp_lsp.default_capabilities()
      )

      -- ── Mason のセットアップ ──────────────────────────
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      -- ── Mason-LSPConfig: 自動インストール & セットアップ
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",     -- Lua
          "ts_ls",      -- TypeScript/JavaScript
          "pyright",    -- Python
          "bashls",     -- Bash
          "jsonls",     -- JSON
          "yamlls",     -- YAML
          "html",       -- HTML
          "cssls",      -- CSS
        },
        automatic_installation = false,
      })

      -- ── 各 LSP サーバーの個別設定 ────────────────────
      local lspconfig = require("lspconfig")

      -- Mason で管理される LSP サーバーを自動セットアップ
      require("mason-lspconfig").setup_handlers({
        -- デフォルトハンドラ: 特別な設定なしで起動
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,

        -- lua_ls: Neovim Lua 開発用の特別設定
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT", -- Neovim は LuaJIT を使用
                },
                diagnostics = {
                  globals = { "vim" }, -- vim グローバル変数を認識
                },
                workspace = {
                  -- Neovim ランタイムファイルを認識
                  library = {
                    vim.env.VIMRUNTIME,
                    vim.fn.stdpath("config") .. "/lua",
                  },
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false, -- テレメトリを無効化
                },
                completion = {
                  callSnippet = "Replace",
                },
              },
            },
          })
        end,

        -- jsonls: スキーマ補完を有効化
        ["jsonls"] = function()
          lspconfig.jsonls.setup({
            capabilities = capabilities,
            settings = {
              json = {
                validate = { enable = true },
              },
            },
          })
        end,
      })
    end,
  },
}
