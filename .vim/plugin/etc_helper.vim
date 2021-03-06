
" ProjectInit, ProjectRefresh , ProjectSet {{{1
function! s:project_init()
  CSInit
  CTProject init
endfunction

function! s:project_refresh()
  CSRefresh
  CTProject refresh
endfunction

function! s:project_set()
  CSSet
  CTProject set
endfunction

command! -nargs=0 -bar ProjectInit call s:project_init()
command! -nargs=0 -bar ProjectRefresh call s:project_refresh()
command! -nargs=0 -bar ProjectSet call s:project_set()

" }}}1

" OpenDirFilePos {{{1

function! s:open_dir_file_pos()
  let l:current_filename = expand("%:p:t")
  let l:current_dir = getcwd()
  execute("e " . escape(expand("%:p:h"), " "))
  set nu
  try
    let line = searchpos(l:current_filename)
    if line[0] == 0 && line[1] == 0
      throw "E35"
    endif
  catch /E35/
    let line = searchpos(l:current_dir)
  endtry
endfunction
command! -nargs=0 -bar OpenDirFilePos call s:open_dir_file_pos()

"}}}1

" vim: set fdm=marker:
