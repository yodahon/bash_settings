"e $MYVIMRC
"mouse
"se mouse=a

let $MYVIMDIR=".vim"
if has("win32") || has("win64")
    let $MYVIMDIR="vimfiles"
endif

"screen
syntax enable
se bg=dark
se laststatus=2
se statusline=\(%n\)%<%f\ %h%m%r%=0x%B\ \ \ \ %-14.(%l,%c%V%)\ %P
se nowrap
se nu
se cursorline
se cursorcolumn
if has("gui_running")
  se paste      "This option have side effect for fuf plugin in terminal
endif


"color
colorscheme evening
if has("gui_running")
    "colorscheme murphy
    "colorscheme ron
    se go-=T
    se go+=m
    "behave mswin
    if has("win32") || has("win64")
        set guifont=DejaVu_Sans_Mono:h12:cANSI
    elseif has("gui_gtk")
        set guifont=DejaVu\ Sans\ Mono\ 12
    elseif has("gui_macvim")
        set guifont=DejaVu\ Sans\ Mono:h14.00
    endif
else
    colorscheme default
endif
se bg=dark

  "80 line over mark
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.*/


"search
se hls ic


"auto chdir dir
autocmd BufEnter * silent! lcd %:p:h:gs/ /\\ /

filetype plugin indent on
se backup
se backupdir=$HOME/$MYVIMDIR/backups

"tags
set tags=./tags,./../tags,./../../tags,./../../../tags,./*/tags

"ftplugin "using \K
runtime ftplugin/man.vim 

"tab
"/* vim:set sts=4: */
se modeline
"set ts=8 sts=4 sw=4 et ai bs=2
set ts=4 sts=4 sw=4 et ai bs=2

"key map
                                           "etc_helper.vim
nnoremap <silent> - <ESC>:OpenDirFilePos<CR>
nnoremap <silent> <F3> <ESC>:hide<CR>
nnoremap <silent> <F4> <ESC>:close<CR>
                                           "for YankRing plugin
nnoremap <silent> <F2> :YRShow<CR>    
                                           "for taglist plugin
nnoremap <silent> <F8> :TlistToggle<CR> 
nnoremap <silent> <F9> :OpenTerminal<CR>
nnoremap <silent> <F10> :OpenShell<CR><CR>
let g:CS_key = 1
if has("gui_running")
  nnoremap <silent> <C-s>   <ESC>:w<CR>
endif
nnoremap <silent> <C-f>s   <ESC>:w<CR>

"for MRU plugin
let MRU_Max_Entries = 200
"for YankRing plugin
let g:yankring_history_dir="$HOME/$MYVIMDIR"
"hide hidden file for netrw plugin
let g:netrw_list_hide = "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"
let g:netrw_keepdir = 0

"about fold
"autocmd BufWinLeave * if expand("%") != "" | mkview | endif
"autocmd BufWinEnter * if expand("%") != "" | loadview | endif
"se foldmethod=syntax "marker "indent
"se foldopen=all
"se foldclose=all
"se foldcolumn=4


"fuf settings
  let g:fuf_modesDisable = []
  let g:fuf_abbrevMap = {
        \   '^vr:' : map(filter(split(&runtimepath, ','), 'v:val !~ "after$"'), 'v:val . ''/**/'''),
        \   '^m0:' : [ '/mnt/d/0/', '/mnt/j/0/' ],
        \ }
  let g:fuf_mrufile_maxItem = 300
  let g:fuf_mrucmd_maxItem = 400
  nnoremap <silent> <C-n>      :FufBuffer<CR>
  nnoremap <silent> <C-p>      :FufFileWithCurrentBufferDir<CR>
  "nnoremap <silent> <C-f><C-p> :FufFileWithFullCwd<CR>
  nnoremap <silent> <C-f>p     :FufFile<CR>
  "nnoremap <silent> <C-f>D     :FufDir<CR>
  nnoremap <silent> <C-j>      :FufMruFile<CR>
  nnoremap <silent> <C-k>      :FufMruCmd<CR>
  "nnoremap <silent> <C-b>      :FufBookmark<CR>
  nnoremap <silent> <C-f><C-t> :FufTag<CR>
  nnoremap <silent> <C-f>t     :FufTag!<CR>
  "noremap  <silent> g]         :FufTagWithCursorWord!<CR>
  nnoremap <silent> <C-f>f     :FufTaggedFile<CR>
  nnoremap <silent> <C-f><C-j> :FufJumpList<CR>
  nnoremap <silent> <C-f><C-g> :FufChangeList<CR>
  nnoremap <silent> <C-f><C-q> :FufQuickfix<CR>
  "nnoremap <silent> <C-f><C-b> :FufAddBookmark<CR>
  "vnoremap <silent> <C-f><C-b> :FufAddBookmarkAsSelectedText<CR>
  "nnoremap <silent> <C-f><C-e> :FufEditInfo<CR>
  nnoremap <silent> <C-f><C-r> :FufRenewCache<CR>
let g:yankring_replace_n_pkey = ""
let g:yankring_replace_n_nkey = ""

"http://www.vi-improved.org/color_sampler_pack/
"

let tlist_actionscript_settings = 'actionscript;c:class;f:method;p:property;v:variable'

"for cp
let g:acp_behaviorSnipmateLength = 1
