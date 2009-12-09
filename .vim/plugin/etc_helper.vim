function! SelectIndent ()
  let temp_var=indent(line("."))
  while indent(line(".")-1) >= temp_var
    exe "normal k"
  endwhile
  exe "normal v"
  while indent(line(".")+1) >= temp_var
    exe "normal j"
  endwhile
endfunction
nmap <space> :call SelectIndent()<cr>


function! s:project_init()
  CSInit
  CTInit
endfunction

function! s:project_refresh()
  CSRefresh
  CTRefresh
endfunction

function! s:project_set()
  CSSet
  CTSet
endfunction

command! -nargs=0 -bar ProjectInit call s:project_init()
command! -nargs=0 -bar ProjectRefresh call s:project_refresh()
command! -nargs=0 -bar ProjectSet call s:project_set()

