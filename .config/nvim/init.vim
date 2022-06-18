"    _____             _   _       _
"   / ____|           | | (_)     | |
"  | (___  _ __   __ _| |_ _  ___ | | __ _ _ __ ___
"   \___ \| '_ \ / _` | __| |/ _ \| |/ _` | '_ ` _ \
"   ____) | | | | (_| | |_| | (_) | | (_| | | | | | |
"  |_____/|_| |_|\__,_|\__|_|\___/|_|\__,_|_| |_| |_|
"
" Filename:   .vimrc
" Github:     https://github.com/Snatiolam/Dots/
" Maintainer: Santiago Alzate (Snatiolam)

" Makes vim more useful
set backspace=indent,eol,start
set cmdheight=2
set encoding=utf-8
set nowrap
" set backup

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey

" "------ Plugins added with plug ------" "
" call plug#begin('~/.vim/plugged')
"
"    Plug 'tpope/vim-fugitive'

"    " Themes "
"    Plug 'morhetz/gruvbox'
"    Plug 'tanvirtin/monokai.nvim'


"   " Status line"
"    Plug 'vim-airline/vim-airline'
"    Plug 'vim-airline/vim-airline-themes'

"    Plug 'mbbill/undotree'"
"    Plug 'preservim/nerdtree'
"    Plug 'potatoesmaster/i3-vim-syntax'
"    Plug 'xuyuanp/nerdtree-git-plugin'
"    Plug 'jiangmiao/auto-pairs'

"   " --- HTML / CSS Plugins"
"    Plug 'alvan/closetag.vim'
"    Plug 'ap/vim-css-color'

"   Important download { python3-dev, nodejs(npm), Go and cmake}
"   Then run (install.py | install.sh)
"    Plug 'Valloric/YouCompleteMe'
"    Plug 'junegunn/fzf', { 'do': { -> fzf#install()  }  }
"    Plug 'junegunn/fzf.vim'
"    Plug 'fladson/vim-kitty'

"" Snippets
"    Plug 'L3MON4D3/LuaSnip'

"" Neovim lsp Plugins
"    " Language Server Protocol (Neovim Nightly required)
"    Plug 'neovim/nvim-lspconfig'
"    " Auto completion with lsp
"    Plug 'hrsh7th/cmp-nvim-lsp'
"    Plug 'hrsh7th/nvim-cmp'

" call plug#end()

" " Call init.lua "
"lua require("init")

" The color scheme of vim ( pablo is preferred as default )
colorscheme pablo
" Recommended if you are using gruvbox
" set background=dark
"let g:gruvbox_invert_selection='0'

syntax on
filetype plugin on

let g:airline_theme='murmur'

" Better file navigation
set path+=**
set wildmenu
set hidden

" Correct splitting windows
set splitbelow splitright

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" When no filetype specified indents at same level from previous lines
set autoindent
" Display the cursor position on the last line of the screen or in the status
" " line of a window
set ruler
set laststatus=2

let $FZF_DEFAULT_OPTS='--reverse'
let g:currentmode={
       \ 'n'  : 'NORMAL',
       \ 'v'  : 'VISUAL',
       \ 'V'  : 'V·Line',
       \ "\<C-v>" : 'V·Block',
       \ 'i'  : 'INSERT',
       \ 'R'  : 'R',
       \ 'Rv' : 'V·Replace',
       \ 'c'  : 'Command',
       \ 't'  : 'Terminal',
       \}

"set statusline=
"set statusline+=%#NormalColor#%{(mode()=='n')?'\ \ '.currentmode[mode()].'\ ':''}
"set statusline+=%#InsertColor#%{(mode()=='i')?'\ \ '.currentmode[mode()].'\ ':''}
"set statusline+=%#VisualColor#%{(mode()=='v')?'\ \ '.currentmode[mode()].'\ ':''}
"set statusline+=%#ReplaceColor#%{(mode()=='R')?'\ \ '.currentmode[mode()].'\ ':''}
""set statusline+=%1*\ %{toupper(currentmode[mode()])}\
"set statusline+=%2*\ %f%m%r\
"set statusline+=%= "Align statusline to the right"
"set statusline+=%4*\ %{&filetype}\
"set statusline+=%3*\ %{&fileencoding}
"set statusline+=[%{&ff}]\
"set statusline+=%1*\ %p%%\
"set statusline+=>>
"set statusline+=\ %l/%L\
"set statusline+=Col:\ %c\

"hi NormalColor cterm=bold guifg=Black guibg=Green ctermbg=Grey ctermfg=Black
"" 191 DarkOliveGreen1 #d7ff5f 256 color-term
"hi InsertColor cterm=bold guifg=Black guibg=Green ctermbg=191 ctermfg=Black
"" 205 HotPink #ff5faf
"hi VisualColor cterm=bold guifg=Black guibg=Green ctermbg=205 ctermfg=Black
"" 214 Orange1 #ffaf00
"hi ReplaceColor cterm=bold guifg=Black guibg=Green ctermbg=214 ctermfg=Black

"hi User1 cterm=bold ctermfg=white ctermbg=Grey
"hi User2 cterm=bold ctermfg=white ctermbg=Black
"hi User3 cterm=bold ctermfg=white ctermbg=DarkGrey
"hi User4 cterm=bold ctermfg=white ctermbg=Black
" hi StatusLine guibg=White ctermfg=8 guifg=DarkSlateGray ctermbg=15
" hi StatusLine cterm=bold ctermbg=red ctermfg=white

" Let not beeping nor flashing when doing something wrong
set visualbell
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" UI - More beauty
set number
set relativenumber
set showcmd
set cursorline
set signcolumn=yes

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F2>

" Tabs and spaces
set shiftwidth=4
set softtabstop=4
set expandtab

" Undo
set undodir=~/.vim/undodir
set undofile

" By default the <leader> key is mapped to \
let mapleader = " "

" Mappings
" No arrow keys for learning
noremap <left> <NOP>
noremap <down> <NOP>
noremap <up> <NOP>
noremap <right> <NOP>

" Spelling toggle
noremap <leader>m :setlocal spell! spelllang=en_us<CR>
hi SpellBad ctermbg=red

nmap <leader>gs :Git<CR>

" "------ NerdTree Settings--------" "
nnoremap <C-n> :NERDTreeToggle<CR>

" "------ UndoTree Settings--------" "
nnoremap <C-u> :UndotreeToggle<CR>

nnoremap <leader>+ :vertical resize +5<CR>
nnoremap <leader>- :vertical resize -5<CR>

" "---- Alias to to quit and save faster ----" "
nnoremap <leader>q :q<CR>
nnoremap <leader>w :w<CR>

" "---- Alias to split window with a new file ----" "
nnoremap <leader>h :split<Space>
nnoremap <leader>v :vsplit<Space>

" "---- Alias to split window with a new file ----" "
" <C-w>h == :wincmd h<CR>
map <leader>h :wincmd h<CR>
map <leader>j :wincmd j<CR>
map <leader>k :wincmd k<CR>
map <leader>l :wincmd l<CR>

" "---- Alias to substite al occurrences -----" "
nnoremap <leader>s :%s//gI<left><left><left>

" " Fuzzy finder (fzf) " "
map <Leader>p :Files<CR>
map <Leader>ob :Buffers<CR>

" " Awesome Remaps " "
" Now undo breaks without exiting insert mode an loose everything you wrote
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ? ?<c-g>u
inoremap ! !<c-g>u
inoremap ] ]<c-g>u

" Yank to clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y

" Same as D or C, so it is more intuitive
nnoremap Y y$

" Move text
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
inoremap <C-j> <esc>:m .+1<CR>==
inoremap <C-k> <esc>:m .-2<CR>==
nnoremap <leader>j :m .+1<CR>==
nnoremap <leader>k :m .-2<CR>==

" "---- YCM Auto completion Settings -------" "
" nnoremap <leader>gd :YcmCompleter GoTo<CR>
" nnoremap <leader>gf :YcmCompleter FixIt<CR>

augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 150})
augroup END

augroup formatting
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
augroup END

" ++----------------- sdsa  ++------------------------
" <C-g>       : Shows me the state of the current file
"
" ----------- Useful motions----------------
" $ or <End>  : Move to the end of line
" g_          : Move to last not blank character of the line
" 0 or <Home> : Move to the first character of the line
" ^           : Move to the first character not blank character of the line
" f{char}     : Move cursor to the next ocurrence of {char}
" t{char}     : Move cusor to till the next currence of {char}
"   ;         : Repeat previous f, t, F, T motion
"   ,         : Repeat previous f, t, F, T motion but in reverse
"  %          : Move to matching character (default supported pairs: '()', '{}', '[]')
"  H          : Move to top of the screen
"  M          : Move to the middle of the screen
"  L          : Move to the bottom of the screen
"  <C-e>      : Move screen down one line (without moving cursor)
"  <C-y>      : Move screen up one line (without moving cursor)
"  {          : Move cursor to the beginning of the previous block
"  }          : Mode cursor to the end of the next block
"
" ----------- Useful operators ---------------
"  d          : delete
"  c          : change
"
"  ---------- Editing text --------------------
