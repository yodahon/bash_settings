function! s:open_terminal()
    if has("mac")
"fill me with below hint
"--
"on process_item(this_item)
    "set the_path to POSIX path of this_item
    "repeat until the_path ends with "/"
        "set the_path to text 1 thru -2 of the_path
    "end repeat
    
    "set cmd to "cd " & quoted form of the_path & " && echo $'\\ec'"
    
    "tell application "System Events" to set terminalIsRunning to exists application process "Terminal"
    
    "tell application "Terminal"
        "activate
        "if terminalIsRunning is true then
            "do script with command cmd
        "else
            "do script with command cmd in window 1
        "end if
    "end tell
    
"end process_item

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
        !open .
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
