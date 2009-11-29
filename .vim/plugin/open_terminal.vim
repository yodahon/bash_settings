function! s:open_terminal()
    if has("mac")

    elseif has("gui_gnome")
        call system("gnome-terminal &") 
    elseif has("gui_win32")
        !cmd &
    elseif executable("bash")
        !bash
    endif
endfunction

function! s:open_shell()
    if has("mac")

    elseif has("gui_gnome")
        call system("nautilus . &") 
    elseif has("gui_win32")
        !explorer . &
    elseif executable("bash")
        !bash
    endif
endfunction

command! -nargs=0 -bar OpenTerminal call s:open_terminal()
command! -nargs=0 -bar OpenShell call s:open_shell()
