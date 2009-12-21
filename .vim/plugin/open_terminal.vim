function! s:open_terminal()
  if has("mac")
    let l:cmd = "
      \ tell application 'System Events'            \n
      \   set terminalIsRunning to exists application process '$Terminal' \n
      \ end tell                                    \n
      \
      \ set cmd to 'cd $current_path'               \n
      \ tell application '$Terminal'                \n
      \   activate                                  \n
      \   if terminalIsRunning is true then         \n
      \     do script with command cmd              \n
      \   else                                      \n
      \     do script with command cmd in window 1  \n
      \   end if                                    \n
      \ end tell                                    \n
      \ "
    let l:cmd = substitute(l:cmd,  "'", '\\"', 'g') 
    let l:cmd = substitute( l:cmd, "$Terminal", "Terminal", "g" )
    let l:cmd = substitute( l:cmd, "$current_path", "'" . expand("%:p:h") . "'" , "g")
    call system('osascript -e " ' . l:cmd . '"')

  elseif has("gui_gnome")
    call system("gnome-terminal &") 
  elseif has("gui_win32")
    !cmd &
  elseif executable("bash")
    !bash
  endif
endfunction

function! s:open_shell()
  let l:cmd = "$cmd ." 

  let l:current_dir = getcwd()
  execute("chdir " . substitute(expand("%:p:h"), " ", '\\ ', "g"))

  if has("mac")
    call system(substitute(l:cmd, "$cmd", "open", ""))
  elseif has("gui_gnome")
    call system(substitute(l:cmd, "$cmd", "nautilus", ""))
  elseif has("gui_win32")
    call system(substitute(l:cmd, "$cmd", "explorer", ""))
  elseif executable("bash")
    !bash
  endif

  execute("chdir " . l:current_dir)
endfunction

command! -nargs=0 -bar OpenTerminal call s:open_terminal()
command! -nargs=0 -bar OpenShell call s:open_shell()
