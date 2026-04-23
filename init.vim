" Install
" ln -s ~/code/configure/init.vim ~/.config/nvim/init.vim
"
"
" Some notes for lspconfig 
" - ruby-lsp: first install it `gem install ruby-lsp`


" ==================== basic config =================== 
set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set scrolloff=5
set incsearch               " incremental search
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=80                  " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set spell                 " enable spell check (may need to download language package)
set noswapfile            " disable creating swap file
let mapleader="\<Space>"
" set backupdir=~/.cache/vim " Directory to store backup files.
set completeopt=menu,menuone,noselect



inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

nnoremap <Leader>wn <C-w><C-w>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nmap <Up>    <Nop>
nmap <Down>  <Nop>
nmap <Left>  <Nop>
nmap <Right> <Nop>

nnoremap K     <C-u>
nnoremap J     <C-d>
nnoremap H     ^
nnoremap L     $

set expandtab
set tabstop=2
set shiftwidth=2

autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype tex setlocal ts=2 sts=2 sw=2 indentexpr=
autocmd Filetype sh setlocal ts=2 sts=2 sw=2
autocmd Filetype cpp setlocal ts=2 sts=2 sw=2
autocmd Filetype markdown setlocal ts=2 sts=2 sw=2


" ======================= auto read =========================

" This is the old way to do it.
" check one time after 4s of inactivity in normal mode
" set autoread
" au CursorHold * checktime

" New way using uvloop
lua << EOF
local w = vim.loop.new_fs_event()
local function on_change(err, fname, status)
  vim.api.nvim_command('checktime')
  w:stop()
  watch_file(fname)
end
function watch_file(fname)
  local fullpath = vim.api.nvim_call_function(
    'fnamemodify', {fname, ':p'})
  w:start(fullpath, {}, vim.schedule_wrap(function(...)
    on_change(...) end))
end
vim.api.nvim_command(
  "command! -nargs=1 Watch call luaeval('watch_file(_A)', expand('<args>'))")
EOF
autocmd VimEnter * :Watch %

" ==================== provider =================== 

" checkout https://neovim.io/doc/user/provider.html
let g:python3_host_prog = '/Users/xiongding/.pyenv/versions/3.11.2/bin/python'


" ==================== plugins =================== 
lua require('plugins')
call plug#begin()
 Plug 'Mofiqul/dracula.nvim'
 Plug 'jparise/vim-graphql'
 Plug 'godlygeek/tabular'
 Plug 'preservim/vim-markdown'
call plug#end()

lua require('plugins')

" ==================== theme =================== 
" colorscheme dracula
" colorscheme nightfox
" colorscheme onedark
" lua <<EOF
" require('onedark').setup {
"     style = 'darker'
" }
" require('onedark').load()
" EOF

if (has("termguicolors"))
 set termguicolors
endif
colorscheme OceanicNext

" ==================== markdown =================== 
let g:vim_markdown_folding_disabled = 1
nnoremap <Leader>mp :Glow<CR>

" ==================== nerdtree =================== 
nnoremap <leader>nt :NvimTreeToggle <bar> wincmd w<CR>
nnoremap <leader>nf :NvimTreeFindFile <bar> wincmd w<CR>
nnoremap <leader>nc :NvimTreeCollapse<CR>
nnoremap <leader>nu :NvimTreeResize +10<CR>
nnoremap <leader>nd :NvimTreeResize -10<CR>

" ==================== plugin config ===================

lua << EOF
require'nvim-web-devicons'.setup {
 -- your personnal icons can go here (to override)
 -- you can specify color or cterm_color instead of specifying both of them
 -- DevIcon will be appended to `name`
 override = {
  zsh = {
    icon = "",
    color = "#428850",
    cterm_color = "65",
    name = "Zsh"
  }
 };
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
}
EOF


" ==================== telescope 
" nnoremap <leader>ff <cmd>Telescope find_files<cr>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fg :lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fr <cmd>Telescope resume<cr>
nnoremap <leader>fp <cmd>Telescope pickers<cr>
nnoremap <leader>fq <cmd>Telescope quickfix<cr>
nnoremap <leader>gr <cmd>Telescope lsp_references<cr>


nnoremap <leader>fs <cmd>Telescope session-lens search_session<cr>

lua << EOF

-------------------  utility functions begin --------------------

-------------------  utility functions end --------------------


require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = false,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {
      { 
        'filename', 
        file_status = true, 
        path = 3
      },
    },
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {{'filename', path=3}},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

vim.keymap.set('n', '<leader>ff', function()
  local current_folder = vim.fn.getcwd()

  if vim.endswith(current_folder, "code/chromium") then
    vim.ui.input({ prompt = 'Find files matching: ' }, function(input)
      if input and input ~= "" then
        require('telescope.builtin').find_files({ search_file = input })
      else
        require('telescope.builtin').find_files({})
      end
    end)
  else
    require('telescope.builtin').find_files({})
  end

end, opts)


-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end


-- ==================== nvim-cmp
  local cmp = require("cmp")
  local luasnip = require("luasnip")

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),

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
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()


  -- configure pyright
  local function find_folders_with_prefix(path, prefix)
    local folders = {}
    if vim.uv.fs_stat(path) then
      for _, file in pairs(vim.fn.readdir(path)) do
        local stat = vim.uv.fs_stat(path .. "/" .. file)
        if stat and stat.type == "directory" and file:sub(1, #prefix) == prefix then
            table.insert(folders, file)
        end
      end
    end
    return folders
  end

  local function build_pyright_settings()
    local pyright_settings = {}
    local pyright_env = {}

    local current_folder = vim.fn.getcwd()
    local existing_python_path = os.getenv("PYTHONPATH") or ""

    if vim.endswith(current_folder, "code/terraform") then
      path = "/Users/xiongding/.local/share/virtualenvs"
      local folders = find_folders_with_prefix(path, "prod-")
      if #folders == 1 then
        py_path = path .. "/" .. folders[1] .. "/bin/python"
        print("pyirght python path: " .. py_path)
        pyright_settings = {
          python = {
            pythonPath = py_path,
            -- this repo add the root dir to sys.path, so we need to tell pyright
            -- however, extraPaths param does not work somehow. Instead, just 
            -- set PYTHONPATH.
            extraPaths = {current_folder},
          }
        }
        pyright_env = {PYTHONPATH = current_folder}
      else
        print("No virtualenvs folder found for terraform project")
      end
    elseif vim.endswith(current_folder, "evergreen") then
      local new_py_path = current_folder .. "/airflow/dags" .. ":" .. existing_python_path
      pyright_env = {PYTHONPATH = new_py_path}
      -- vim.print(new_py_path)
    end

    return pyright_settings, pyright_env
  end
 
  pyright_settings, pyright_env = build_pyright_settings()

  require'lspconfig'.pyright.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = {'pyright-langserver', '--stdio' },
    cmd_env = pyright_env,
    settings = pyright_settings,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    }
  }
  
  require'lspconfig'.clangd.setup{
    capabilities = capabilities,
    on_attach = on_attach,
  }

  local function build_gopls_settings() 
    local settings = {}
    local current_folder = vim.fn.getcwd()

    if vim.endswith(current_folder, "code/datadog-agent") then
      settings = {
        buildFlags = { "-tags=kubeapiserver" }
      }
    end
    return settings
  end

  require'lspconfig'.gopls.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      gopls = build_gopls_settings(),
    },
  }

  require'lspconfig'.lua_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim'},
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  }

  require'lspconfig'.ts_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }

  require'lspconfig'.rust_analyzer.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      ['rust-analyzer'] = {
        diagnostics = {
          enable = false;
        }
      }
    }
  }
  
  require'lspconfig'.ruby_lsp.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      single_file_support = true,
    }
  }

  require'lspconfig'.bashls.setup{}

  -- ==================== treesitter
  require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = { "c", "lua", "cpp", "python", "javascript", "typescript", "markdown", "rust", "yaml", "go" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- List of parsers to ignore installing (for "all")
    ignore_install = { "markdown" },

    highlight = {
      -- `false` will disable the whole extension
      enable = true,

      -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
      -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
      -- the name of the parser)
      -- list of language that will be disabled
      disable = { "markdown" },

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },

    textobjects = {
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
    },
  }

  require'treesitter-context'.setup{
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          -- For all filetypes
          -- Note that setting an entry here replaces all other patterns for this entry.
          -- By setting the 'default' entry below, you can control which nodes you want to
          -- appear in the context window.
          default = {
              'class',
              'function',
              'method',
              -- 'for', -- These won't appear in the context
              -- 'while',
              -- 'if',
              -- 'switch',
              -- 'case',
          },
          -- Example for a specific filetype.
          -- If a pattern is missing, *open a PR* so everyone can benefit.
          --   rust = {
          --       'impl_item',
          --   },
      },
      exact_patterns = {
          -- Example for a specific filetype with Lua patterns
          -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
          -- exactly match "impl_item" only)
          -- rust = true,
      },

      -- [!] The options below are exposed but shouldn't require your attention,
      --     you can safely ignore them.

      zindex = 20, -- The Z-index of the context window
      mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
      separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
  }

  -- ==================== toggleterm
  require("toggleterm").setup{
    open_mapping = [[<c-\>]],
    direction = "float",
  }

  -- ==================== bufferline
  vim.opt.termguicolors = true

  require('bufferline').setup {
    options = {
      mode = "buffers", -- set to "tabs" to only show tabpages instead
      numbers = "buffer_id",
      close_command = "bdelete! %d",       -- can be a string | function, see "Mouse actions"
      right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
      left_mouse_command = "buffer %d",    -- can be a string | function, see "Mouse actions"
      middle_mouse_command = nil,          -- can be a string | function, see "Mouse actions"
      -- NOTE: this plugin is designed with this icon in mind,
      -- and so changing this is NOT recommended, this is intended
      -- as an escape hatch for people who cannot bear it for whatever reason
      indicator = {
          icon = '▎',
          style = 'icon',
      },
      buffer_close_icon = '',
      modified_icon = '●',
      close_icon = '',
      left_trunc_marker = '',
      right_trunc_marker = '',
      --- name_formatter can be used to change the buffer's label in the bufferline.
      --- Please note some names can/will break the
      --- bufferline so use this at your discretion knowing that it has
      --- some limitations that will *NOT* be fixed.
      name_formatter = function(buf)  -- buf contains a "name", "path" and "bufnr"
        -- remove extension from markdown files for example
        if buf.name:match('%.md') then
          return vim.fn.fnamemodify(buf.name, ':t:r')
        end
      end,
      max_name_length = 18,
      max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
      tab_size = 18,
      diagnostics = false,
      diagnostics_update_in_insert = false,
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        return "("..count..")"
      end,
      -- NOTE: this will be called a lot so don't do any heavy processing here
      custom_filter = function(buf_number, buf_numbers)
        -- filter out filetypes you don't want to see
        if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
          return true
        end
        -- filter out by buffer name
        if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
          return true
        end
        -- filter out based on arbitrary rules
        -- e.g. filter out vim wiki buffer from tabline in your work repo
        if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
          return true
        end
        -- filter out by it's index number in list (don't show first buffer)
        if buf_numbers[1] ~= buf_number then
          return true
        end
      end,
      offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "left"}},
      color_icons = true, -- whether or not to add the filetype icon highlights
      show_buffer_icons = true, -- disable filetype icons for buffers
      show_buffer_close_icons = true,
      show_close_icon = true,
      show_tab_indicators = true,
      persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
      -- can also be a table containing 2 custom separators
      -- [focused and unfocused]. eg: { '|', '|' }
      separator_style = "slant",
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      sort_by = 'insert_after_current',
    }
  }


  -- ==================== 
  require("nvim-tree").setup({
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      adaptive_size = false,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
    },
    actions = {
        open_file = {
            resize_window = true,
        },
    },
    -- when session-lens used, we need to follow a different root
    -- update_focused_file = {
    --   enable = true,
    --   update_root = true,
    -- },
  })


  -- ==================== gitlinker
  require"gitlinker".setup()

  -- ======================================== 
  require("indent_blankline")
  require('bqf').setup()
  

  -- ======================================== 
  local lga_actions = require("telescope-live-grep-args.actions")
  require('telescope').setup{
    defaults = {
      preview = {
        timeout = 500,
      },
      cache_picker = {
        num_pickers = 5,
      },
      -- Default configuration for telescope goes here:
      -- config_key = value,
      mappings = {
        i = {
          -- map actions.which_key to <C-h> (default: <C-/>)
          -- actions.which_key shows the mappings for your picker,
          -- e.g. git_{create, delete, ...}_branch for the git_branches picker
          ["<C-h>"] = "which_key"
        }
      }
    },
    pickers = {
      -- Default configuration for builtin pickers goes here:
      -- picker_name = {
      --   picker_config_key = value,
      --   ...
      -- }
      -- Now the picker_config_key will be applied every time you call this
      -- builtin picker
      find_files = {
        hidden = false,
      },
    },
    extensions = {
      live_grep_args = {
        auto_quoting = true, -- enable/disable auto-quoting
        -- override default mappings
        -- default_mappings = {},
        mappings = { -- extend mappings
          i = {
            ["<C-k>"] = lga_actions.quote_prompt(),
          }
        }
        -- ... also accepts theme settings, for example:
        -- theme = 'dropdown', -- use dropdown theme
        -- layout_config = { mirror=true }, -- mirror preview pane
      },
    }
  }



  -- ============================================
  vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true})
  vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
  vim.keymap.set('v', '<leader>c', require('osc52').copy_visual)

  -- ============================================
  --        Custom definitions
  -- ============================================

  local M = {}

  function M.toggle_test_file()
    local current_file = vim.api.nvim_buf_get_name(0)
    local path, file_name, extension = current_file:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
    if file_name:sub(1, #"test_") == "test_"  then
      file_name = file_name:sub(#"test_" + 1, -1)
    else
      file_name = "test_" .. file_name
    end

    local corresponding_file = path .. file_name

    if vim.fn.filereadable(corresponding_file) == 0 then
      local choice = vim.fn.confirm("File does not exist: " .. corresponding_file .. ". Create it?", "&Yes\n&No", 2)
      if choice == 1 then
        vim.cmd("edit " .. corresponding_file)
      end
      return 
    end

    vim.cmd("e " .. corresponding_file)
  end

  vim.keymap.set('n', '<leader>t', M.toggle_test_file)

  ----- 
  local ts_utils = require('nvim-treesitter.ts_utils')
  local osc52 = require("osc52")

  local function get_enclosing_function_name()
    local node = ts_utils.get_node_at_cursor()
    while node do
      print(node:type())
      if node:type() == 'function_definition' then
        for i=0,node:named_child_count()-1 do
          local child = node:named_child(i)
          if child:type() == 'identifier' then
            return vim.treesitter.get_node_text(child, 0)
          end
        end
      end
      node = node:parent()
    end

    return nil
  end

  function M.get_test_path()
    local current_file = vim.api.nvim_buf_get_name(0)
    local path, file_name, extension = current_file:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
    local function_name = get_enclosing_function_name()
    local full_path = path .. file_name .. "::" .. function_name
    osc52.copy(full_path)
    vim.notify(full_path)
  end

  vim.keymap.set('n', '<leader>tt', M.get_test_path)

EOF
