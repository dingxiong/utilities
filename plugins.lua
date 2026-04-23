-- This file can be loaded by calling `lua require('useins')` from your init.vim
-- 
-- Run below two commands to initialize
-- mkdir -p ~/.config/nvim/lua
-- ln -s ~/code/configure/plugins.lua ~/.config/nvim/lua/plugins.lua 

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'nvim-tree/nvim-web-devicons'

  -- this needs install Nerds Font. brew install font-hack-nerd-font
  -- and then in iTerms2 -> preferences -> profiles -> font choose the 
  -- font just installed
  use {
      'nvim-lualine/lualine.nvim',
      requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets usein use 'neovim/nvim-lspconfig' -- Collection of configurations for the built-in LSP client

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
    requires = {
      {'nvim-lua/plenary.nvim'},
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    config = function()
      require("telescope").load_extension("live_grep_args")
    end
  }
  -- ------------------------ treesitter related ------------------------------
  -- treesitter error: not an editor command TSUpdate
  -- Just restart nvim. TSUpdate command can be found.
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use "nvim-treesitter/nvim-treesitter-textobjects"
  use 'nvim-treesitter/nvim-treesitter-context'


  -- install glow first: brew install glow
  use {"ellisonleao/glow.nvim", config = function() require("glow").setup() end}


  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end}

  use {
    'akinsho/bufferline.nvim', tag = "*",
    requires = 'nvim-tree/nvim-web-devicons'
  }

  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
  }

  -- git related
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        current_line_blame = true,
      }
    end
  }

  use 'nvim-lua/plenary.nvim'

  use {
    'dingxiong/gitlinker.nvim',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'ojroques/nvim-osc52'},
    },
  }

  -- 
  use {'kevinhwang91/nvim-bqf'}


  -- indent
  use "lukas-reineke/indent-blankline.nvim"


  -- ------------ Session management ---------
  use {
    'rmagatti/auto-session',
    config = function()
      vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
      require('auto-session').setup {
        log_level = 'info',
        auto_session_suppress_dirs = {'~/', '~/Projects'},
      }
    end
  }

  --use {
    --'rmagatti/session-lens',
    --requires = {'rmagatti/auto-session', 'nvim-telescope/telescope.nvim'},
    --config = function()
      --require('session-lens').setup({[>your custom config--<]})
    --end
  --}

  -- themes 
  use "EdenEast/nightfox.nvim"
  use 'navarasu/onedark.nvim'
  use 'mhartington/oceanic-next'

  -- matchup
  use {
    'andymass/vim-matchup',
    setup = function()
      -- may set any options here
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end
  }

  use {
    "Pocco81/auto-save.nvim",
    config = function()
       require("auto-save").setup {
        -- your config goes here
        -- or just leave it empty :)
       }
    end
  }

  use {'ojroques/nvim-osc52'}

  -- commenter 
  use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
  }

  -- yaml 
  use {
    "cuducos/yaml.nvim",
    ft = { "yaml" }, -- optional
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim" -- optional
    },
  }

end)
