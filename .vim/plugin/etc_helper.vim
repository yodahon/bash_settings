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


function! s:projec_init()
  CSInit
  se cst
  CTInit
endfunction
function! s:projec_refresh()
  CSRefresh
  se cst
  CTRefresh
endfunction
command! -nargs=0 -bar ProjectInit call s:projec_init()
command! -nargs=0 -bar ProjectRefresh call s:projec_refresh()

