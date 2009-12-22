
function! s:map_key()
    "for cscope
    nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>

    " Using 'CTRL-spacebar' then a search type makes the vim window
    " split horizontally, with search result displayed in
    " the new window.

    nmap <C-Space>s :scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-Space>g :scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-Space>c :scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-Space>t :scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-Space>e :scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-Space>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-Space>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-Space>d :scs find d <C-R>=expand("<cword>")<CR><CR>

    " Hitting CTRL-space *twice* before the search type does a vertical
    " split instead of a horizontal one

    "nmap <C-Space><C-Space>s
            "\:vert scs find s <C-R>=expand("<cword>")<CR><CR>
    "nmap <C-Space><C-Space>g
            "\:vert scs find g <C-R>=expand("<cword>")<CR><CR>
    "nmap <C-Space><C-Space>c
            "\:vert scs find :lsc <C-R>=expand("<cword>")<CR><CR>
    "nmap <C-Space><C-Space>t
            "\:vert scs find t <C-R>=expand("<cword>")<CR><CR>
    "nmap <C-Space><C-Space>e
            "\:vert scs find e <C-R>=expand("<cword>")<CR><CR>
    "nmap <C-Space><C-Space>i
            "\:vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    "nmap <C-Space><C-Space>d
            "\:vert scs find d <C-R>=expand("<cword>")<CR><CR>
endfunction

let s:csout_dir = ""

function! s:csout_path()
    return s:csout_dir . "/cscope.out"
endfunction

function! s:make_cscope_out(is_update)
    let not_names = split("tags cscope.out cscope.files *.jar *.png *.gif *.jpg *.bmp")
    let not_name = "-not -name \"" . join(not_names, "\" -not -name \"") . "\""

    let l:csout_cmd = "find " . s:csout_dir . " -type f -not -path \"*/.*\" " . not_name ." -printf \"\\\"\\%p\\\"\\n\" > cscope.files && cscope -b "
    "mac default BSD find utils don't support -printf option
    if has("mac")
     let l:csout_cmd = "find " . s:csout_dir . " -type f -not -path \"*/.*\" " . not_name ." | awk '{print \"\\\"\" $0 \"\\\"\"}' > cscope.files && cscope -b "
    endif
    if a:is_update
        echo l:csout_cmd
        call system(l:csout_cmd . "-U")
    else
        execute("!" . l:csout_cmd)
        if !has("gui_running")
            echo l:csout_cmd
        endif
    endif
    unlet l:csout_cmd
    unlet not_names
    unlet not_name
endfunction    

function! s:add_cscope_out()
    cs kill 0
    execute("cs add " . s:csout_path() )
    set cspc=3
endfunction

function! s:init_cscope()
    let s:csout_dir = getcwd() 
    call s:make_cscope_out(0)
    call s:add_cscope_out()
endfunction

function! s:set_cscope()
    if len(findfile("cscope.out",".")) > 0
        let s:csout_dir = getcwd() 
        call s:add_cscope_out()
    endif
endfunction

function! s:refresh_cscope()
    let current_dir = getcwd()
    execute("chdir " . escape(s:csout_dir, " \"'"))
    call s:make_cscope_out(1)
    echo "refreshed cscope.out"
    call s:add_cscope_out()
    execute("chdir " . escape(current_dir, " \"'"))
    unlet current_dir
endfunction

function! s:update_cscope()
    let current_dir = getcwd()
    execute("chdir " . escape(s:csout_dir, " \"'"))
    cscope -U %:p

    execute("chdir " . escape(current_dir, " \"'"))
    unlet current_dir
endfunction

command! -nargs=0 -bar CSInit call s:init_cscope()
command! -nargs=0 -bar CSSet call s:set_cscope()
command! -nargs=0 -bar CSRefresh call s:refresh_cscope()
command! -nargs=0 -bar CSKey call s:map_key()

if !exists('g:CS_key')
    let g:CS_key = 1
endif

if g:CS_key
    CSKey
endif

