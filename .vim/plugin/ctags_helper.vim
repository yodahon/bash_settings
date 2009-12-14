
if !exists('g:tags_lib')
  let g:tags_lib_dirs = ""
endif

let g:ctags_default_files = split("./tags,./../tags,./../../tags,./../../../tags,./*/tags",',')
let s:tags_lib = ""
let s:project_root = ""

" project management {{{1
function! s:add_tags_dir()
endfunction

function! s:make_ctags()
  let tags_cmd = "ctags -r "
  execute("!" . tags_cmd . s:tags_dir)
  if !has("gui_running")
    echo tags_cmd
  endif
  unlet tags_cmd
endfunction    

function! s:set_tags_dir()
  if filereadable("tags") || filereadable("tags")
    let s:project_root = s:tags_dir
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
" }}}1


" library path management {{{1
"
  " let g:ctags_library_dicts = 
  "   {
  "     filetype1 : {dir1 : "dummy", dir2: "dummy" }, 
  "     filetype2 : {dir1 : "dummy", dir2: "dummy" } 
  "   } 
let g:ctags_library_dicts = {}
let g:ctags_library_applied = {}
let g:ctags_info_file = expand("~/.vim.ctag_helper")

function! s:load_info_file()
  if filereadable(g:ctags_info_file)
    let lines = readfile(g:ctags_info_file)
    if len(lines) > 0
      execute("let g:ctags_library_dicts = " . lines[0])
    endif
  endif
endfunction

call s:load_info_file()

function! s:show_library()
  let l:count = 0
  for filetype in sort(keys(g:ctags_library_dicts))
    for dir in sort(keys(g:ctags_library_dicts[filetype]))
      echo l:count . "   " . filetype . "  " . dir
      let l:count += 1
    endfor
  endfor

endfunction

function! s:remove_library(num)
  let l:count = 0
  for filetype in sort(keys(g:ctags_library_dicts))
    for dir in sort(keys(g:ctags_library_dicts[filetype]))
      if l:count == a:num
        call remove(g:ctags_library_dicts[filetype],dir) 
        break
      endif
      let l:count += 1
    endfor
  endfor

  call s:show_library()
endfunction

function! s:add_library(dir, filetype)
  let l:dirs ={}
  if !has_key(g:ctags_library_dicts, a:filetype)
    let g:ctags_library_dicts[a:filetype] = {}  
  endif
  let l:dir_dicts = g:ctags_library_dicts[a:filetype]

  if filereadable(a:dir . "/tags")
    let l:dir_dicts[a:dir . "/tags"]="dummy"
  else
    let msg = "Din't find tags file. \nDo you make tags with '!ctags -R'? (y/n): "
    if input(msg) == "y"
      let old = getcwd()
      execute("chdir " . a:dir)
      execute("!ctags -R")
      execute("chdir " . old)
      let l:dir_dicts[a:dir . "/tags"]="dummy"
    endif
  endif

  "write file code
  if filereadable(expand(g:ctags_info_file))
    call writefile([string(g:ctags_library_dicts)],expand(g:ctags_info_file))
  endif

  
  "let dirs = split(g:tags_lib_dirs,",")
  "call filter(dirs, 'v:val != s:cwd')
  "call add(dirs, s:cwd)
  "let g:tags_lib_dirs = join(dirs, ',')
  "unlet s:cwd

  call s:show_library()
endfunction


function! s:tags_dict()
  let l:tags_dict = {}
  for tag in split(&tags, ',')
    let l:tags_dict[tag] = "dummy"
  endfor
  return l:tags_dict
endfunction

function! s:set_tags(tags_dict)
  for file in g:ctags_default_files
    let a:tags_dict[file] = "dummy"
  endfor

  "apply tags
  let l:tags = join(sort(keys(a:tags_dict)), ',')
  execute "set tags=" . l:tags
endfunction

function! s:apply_library(...)
  let l:filetypes = {"all":"dummy"}
  windo let l:filetypes[&filetype]="dummy"

  let l:tags_dict = s:tags_dict()

  for filetype in keys(l:filetypes)
    if has_key(g:ctags_library_applied, filetype)
      continue
    endif
    let g:ctags_library_applied[filetype] = "dummy"

    for dir in keys(get(g:ctags_library_dicts, filetype, {}))
      let l:tags_dict[dir] = "dummy"
    endfor
  endfor

  if a:0 == 1 && type(a:1) == 1
    let l:filetype = a:1 
    for dir in keys(get(g:ctags_library_dicts, filetype, {}))
      call remove(l:tags_dict, dir)
    endfor
    call remove(g:ctags_library_applied, filetype)
  endif

  call s:set_tags(l:tags_dict)
endfunction



function! s:manage_library(...) 
  if a:0 == 0
    echo "CTLibrary command"
    echo "add   : add current or target director to library path.   (usage: add [dir] [filetype])"
    echo "remove: remove library paths.     (usage: remove {n}|all"
    echo "        {n} : number"
    echo "        all : all library deleted"
    echo "show  : show library paths"
    echo "  "
    call s:show_library()
  else
    if a:1 == "add"
      let l:dir = a:0 >= 1 ? getcwd() : a:2
      let l:dir = l:dir == "." ? getcwd() : l:dir
      let l:filetype = a:0 == 3 ? a:3 : "all"

      call s:add_library(l:dir, l:filetype)
      call s:apply_library()
    elseif a:1 == "remove"
      call s:remove_library(str2nr(a:2))

    elseif a:1 == "show"
      call s:show_library()
    endif
  endif
endfunction
" }}}1

" define command {{{1
command! -nargs=0 -bar CTInit call s:init_ctags()
command! -nargs=0 -bar CTSet call s:set_tags_dir()
command! -nargs=0 -bar CTRefresh call s:refresh_ctags()
command! -nargs=* -bar CTLibrary call s:manage_library(<f-args>)
" }}}1
" vim: set fdm=marker:
