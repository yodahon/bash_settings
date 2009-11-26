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
command! -nargs=0 -bar CSProject call s:projec_init()

