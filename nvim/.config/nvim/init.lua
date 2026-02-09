-- ── Options ──────────────────────────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number         = true
opt.relativenumber = true
opt.mouse          = "a"
opt.showmode       = false        -- shown in statusline instead
opt.clipboard      = "unnamedplus"
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = false
opt.wrap           = false
opt.breakindent    = true
opt.tabstop        = 2
opt.shiftwidth     = 2
opt.expandtab      = true
opt.splitright     = true
opt.splitbelow     = true
opt.termguicolors  = true
opt.signcolumn     = "yes"
opt.cursorline     = true
opt.scrolloff      = 8
opt.updatetime     = 250

-- ── Lazy.nvim bootstrap ─────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ─────────────────────────────────────────────────────────────
require("lazy").setup({
  -- Tokyo Night — matches tmux, fzf, iTerm2, delta
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "night", transparent = false },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  -- Treesitter — modern syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      local langs = {
        "lua", "javascript", "typescript", "python", "json", "yaml",
        "html", "css", "bash", "markdown", "markdown_inline", "vim",
        "vimdoc", "go", "rust",
      }
      require("nvim-treesitter").install(langs)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = langs,
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- Telescope — fuzzy finder (mirrors fzf muscle memory)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
      telescope.load_extension("fzf")
    end,
    keys = {
      { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
      { "<leader>b", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
      { "<leader>h", "<cmd>Telescope help_tags<cr>",  desc = "Help" },
      { "<leader>r", "<cmd>Telescope oldfiles<cr>",   desc = "Recent files" },
    },
  },

  -- Seamless tmux/vim pane navigation with Ctrl-h/j/k/l
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  -- Minimal statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "tokyonight",
        component_separators = "",
        section_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Comment toggling (gcc / gc in visual)
  { "numToStr/Comment.nvim", opts = {} },

  -- Surround (ys, ds, cs)
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

  -- Autopairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },
}, {
  -- Lazy.nvim UI options
  ui = { border = "rounded" },
  checker = { enabled = false },
  change_detection = { notify = false },
})

-- ── Keymaps ─────────────────────────────────────────────────────────────
local map = vim.keymap.set

-- Window navigation (also handled by vim-tmux-navigator)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Quick save
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })

-- Split management
map("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>-", "<cmd>split<CR>",  { desc = "Horizontal split" })
