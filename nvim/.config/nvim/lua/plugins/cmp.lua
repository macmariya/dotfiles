-- ==========================================================
-- nvim-cmp 補完設定
-- ==========================================================

return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    -- 補完ソース
    "hrsh7th/cmp-nvim-lsp",    -- LSP 補完
    "hrsh7th/cmp-buffer",       -- バッファ内の単語
    "hrsh7th/cmp-path",         -- ファイルパス
    "hrsh7th/cmp-cmdline",      -- コマンドライン補完
    -- スニペットエンジン
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = {
        -- 定義済みスニペット集
        "rafamadriz/friendly-snippets",
      },
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    "saadparwaiz1/cmp_luasnip", -- LuaSnip の cmp ソース
    -- 補完メニューのアイコン
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    cmp.setup({
      -- スニペット展開の設定
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- ウィンドウ外観
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      -- キーマップ
      mapping = cmp.mapping.preset.insert({
        -- 候補の選択
        ["<C-p>"] = cmp.mapping.select_prev_item(), -- 前の候補
        ["<C-n>"] = cmp.mapping.select_next_item(), -- 次の候補

        -- ドキュメントのスクロール
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        -- 補完メニューの表示
        ["<C-Space>"] = cmp.mapping.complete(),

        -- キャンセル
        ["<C-e>"] = cmp.mapping.abort(),

        -- 確定（選択中の候補がある場合のみ）
        ["<CR>"] = cmp.mapping.confirm({ select = false }),

        -- Tab: 候補選択 or スニペットジャンプ
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),

        -- Shift-Tab: 逆方向
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      -- 補完ソースの優先順位
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 }, -- LSP（最優先）
        { name = "luasnip", priority = 750 },   -- スニペット
        { name = "buffer", priority = 500 },     -- バッファ
        { name = "path", priority = 250 },       -- ファイルパス
      }),

      -- フォーマット設定（アイコン表示）
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text", -- アイコン + テキスト
          maxwidth = 50,
          ellipsis_char = "...",
          menu = {
            nvim_lsp = "[LSP]",
            luasnip = "[Snip]",
            buffer = "[Buf]",
            path = "[Path]",
          },
        }),
      },

      -- 実験的機能
      experimental = {
        ghost_text = true, -- ゴーストテキスト（薄く候補を表示）
      },
    })

    -- コマンドラインの補完設定（/ 検索）
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- コマンドラインの補完設定（: コマンド）
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })
  end,
}
