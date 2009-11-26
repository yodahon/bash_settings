
let s:tags_dir = ""

function! s:make_ctags()
    let tags_cmd = "ctags -R "
    execute("!" . tags_cmd . s:tags_dir)
    if !has("gui_running")
        echo tags_cmd
    endif
    unlet tags_cmd
endfunction    

function! s:set_tags_dir()
    if filereadable("tags") || filereadable("TAGS")
        let cmd ="set tags=" . s:tags_dir . "/tags,./tags,./../tags,./../../tags,./../../../tags,./*/tags" 
        execute(cmd)
        echo(cmd)
    endif
endfunction

function! s:init_ctags()
    let s:tags_dir = getcwd() 
    call s:make_ctags()
    call s:set_tags_dir()
endfunction

function! s:refresh_ctags()
    let current_dir = getcwd()
    execute("chdir " . s:tags_dir)
    call s:make_ctags()
    echo "refreshed tags"
    execute("chdir " . current_dir)
    unlet current_dir
endfunction

command! -nargs=0 -bar CTInit call s:init_ctags()
command! -nargs=0 -bar CTSet call s:set_tags_dir()
command! -nargs=0 -bar CTRefresh call s:refresh_ctags()
