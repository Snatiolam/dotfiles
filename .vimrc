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
set nocompatible

" "------ Plugins added with plug ------" "
" call plug#begin('~/.vim/plugged')
"     Plug 'morhetz/gruvbox'
"     Plug 'mbbill/undotree'"
"     Plug 'preservim/nerdtree'
"     Plug 'xuyuanp/nerdtree-git-plugin'
"     Plug 'jiangmiao/auto-pairs'
"   Important download { python3-dev, nodejs(npm), Go and cmake}
"   Then run (install.py | install.sh)
"     Plug 'Valloric/YouCompleteMe'
" call plug#end()

" The color scheme of vim ( pablo is preferred as default )
colorscheme pablo
" Recommended if you are using gruvbox
" set background=dark

syntax on 
filetype plugin on 

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

" set statusline=
" set statusline+=%1*\ %{toupper(currentmode[mode()])}\ 
" set statusline+=%2*\ %f%m%r\ 
" set statusline+=%1*\ %y\ 
" set statusline+=%= "Align statusline to the right"
" set statusline+=Line:\ %l/%L\ 
" set statusline+=Col:\ %c\ 
" set statusline+=-\\%p%%\ 

" hi User1 cterm=bold ctermfg=white ctermbg=Blue 
" hi User2 cterm=bold ctermfg=Blue ctermbg=Black
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
set cursorline
set showcmd 

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

" "------ NerdTree Settings--------" "
"nnoremap <C-n> :NERDTreeToggle<CR>
"
" "------ UndoTree Settings--------" "
"nnoremap <C-u> :UndotreeToggle<CR>

nnoremap <leader>+ :vertical resize +5<CR>
nnoremap <leader>- :vertical resize -5<CR>
" 
" "---- Map vim movement keys ----" "
noremap ; l
noremap l k
noremap k j
noremap j h

" "---- Alias to to quit and save faster ----" "
nnoremap <leader>q :q<CR>
nnoremap <leader>w :w<CR>

" "---- Alias to split window with a new file ----" "
nnoremap <leader>h :split<Space>
nnoremap <leader>v :vsplit<Space>

" "---- Alias to split window with a new file ----" "
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" "---- Alias to substite al occurrences -----" "
nnoremap S :%s//gI<left><left><left>

" "---- YCM Auto completion Settings -------" "
" nnoremap <leader>gd :YcmCompleter GoTo<CR>
" nnoremap <leader>gf :YcmCompleter FixIt<CR>

" "---- Alacritty mouse enabling ---- " "
set ttymouse=sgr

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
