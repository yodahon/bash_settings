

" Utilities : simple log, path separator {{{1
function! s:log(msg)
  call system("echo \"" . escape(a:msg, "\"") . " \" >> ~/temp/vim.log")
endfunction

function! s:separator()
  return (has('win32') || has('win64') ? '\' : '/')
endfunction

" }}}1

" tags option helper {{{1
let g:ctags_default_files = split("./tags,./../tags,./../../tags,./../../../tags,./../../../../tags",',')

function! s:tags_dict()
  let l:tags_dict = {}
  for tag in split(&tags, ',')
    let l:tags_dict[tag] = 1
  endfor
  return l:tags_dict
endfunction

function! s:set_tags(tags_dict)
  for file in g:ctags_default_files
    let a:tags_dict[file] = 1
  endfor

  execute "set tags=" . escape(join(sort(keys(a:tags_dict)), ','), " \"'")
endfunction
" }}}1

" Project management {{{1
let s:project_dir = ""

function! s:make_ctags(project_dir)
  let tags_cmd = "!ctags -R "
  let current_dir = getcwd()
  execute("chdir " . escape(a:project_dir, " \"'"))
  execute(tags_cmd)
  execute("chdir " . escape(current_dir, " \"'"))
  unlet current_dir

  if !has("gui_running")
    echo tags_cmd
  endif
  unlet tags_cmd
endfunction

function! s:set_tags_dir(project_dir)
  let l:project_tag = a:project_dir . "/tags"
  let l:old_project_tag = s:project_dir . "/tags"

  if filereadable(l:project_tag)
    let l:tags_dict = s:tags_dict()
    call filter(l:tags_dict, "v:key != l:old_project_tag")
    let l:tags_dict[l:project_tag] = 1
    call s:set_tags(l:tags_dict)

    let s:project_dir = a:project_dir
  endif
endfunction

function! s:init_ctags()
  call s:make_ctags(getcwd())
  call s:set_tags_dir(getcwd())

  let l:tags_dict = s:tags_dict()
  let l:tags = sort(keys(l:tags_dict))
  echo "tags options"
  echo "    " . join(l:tags,"\n    ")
endfunction

function! s:refresh_ctags()
  let current_dir = getcwd()
  execute("chdir " . escape(s:project_dir, " \"'"))
  call s:make_ctags(s:project_dir)
  echo "refreshed tags"
  execute("chdir " . escape(current_dir, " \"'"))
  unlet current_dir
endfunction

function! s:show_project()
  echo("Project dir : " . s:project_dir)
endfunction

function! s:manage_project(...)
  if a:0 == 0
    echo "CTProject command"
    echo "  init"
    echo "  set"
    echo "  refresh"
    echo "  release"
    echo "  "
  else
    if     a:1 == "init"
      call s:init_ctags()
    elseif a:1 == "set"
      call s:set_tags_dir(getcwd())
    elseif a:1 == "refresh"
      call s:refresh_ctags()
    elseif a:1 == "release"
    endif
  endif
  call s:show_project()
endfunction
" }}}1

" Library management {{{1
"
  " let g:ctags_library_dicts = 
  "   {
  "     filetype1 : {file1 :1, file2: 1}, 
  "     filetype2 : {file1 :1, file: 1} 
  "   } 
if !exists("g:ctags_library_dicts")
  let g:ctags_library_dicts = {}
  let g:ctags_library_applied = {}
  let g:ctags_info_file = expand("~/.vim.ctag_helper")
endif

function! s:load_info_file()
  if filereadable(g:ctags_info_file)
    let lines = readfile(g:ctags_info_file)
    if len(lines) > 0
      execute("let g:ctags_library_dicts = " . lines[0])
    endif
  endif
endfunction

call s:load_info_file()

function! s:save_info_file()
  "if filereadable(expand(g:ctags_info_file))
  call writefile([string(g:ctags_library_dicts)],expand(g:ctags_info_file))
  "endif
endfunction

function! s:show_library()
  echo "library (index   filetype   tags)"
  let l:count = 0
  for filetype in sort(keys(g:ctags_library_dicts))
    for dir in sort(keys(g:ctags_library_dicts[filetype]))
      echo "    " . l:count . "   " . filetype . "  " . dir
      let l:count += 1
    endfor
  endfor

  echo ("applied \n    " . string(sort(keys(g:ctags_library_applied))))
 
  let l:tags_dict = s:tags_dict()
  let l:tags = sort(keys(l:tags_dict))
  echo "tags options"
  echo "    " . join(l:tags,"\n    ")
endfunction


function! s:apply_library(filetype)
  let l:tags_dict = s:tags_dict()

  if has_key(g:ctags_library_applied, a:filetype)
    return
  endif
  let g:ctags_library_applied[a:filetype] =1

  for dir in keys(get(g:ctags_library_dicts, a:filetype, {}))
    let l:tags_dict[dir] = 1
  endfor

  call s:set_tags(l:tags_dict)
endfunction

function! s:unapply_library(filetype)
  let l:tags_dict = s:tags_dict()

  call filter(g:ctags_library_applied, "v:key != a:filetype")
  for dir in keys(get(g:ctags_library_dicts, a:filetype, {}))
    call filter(l:tags_dict, "v:key != dir")
  endfor

  call s:set_tags(l:tags_dict)
endfunction

function! s:remove_library(num)
  let l:filetype = ""
  let l:count = 0
  let l:removed_tag_file = ""
  for filetype in sort(keys(g:ctags_library_dicts))
    for tag_file in sort(keys(g:ctags_library_dicts[filetype]))
      if l:count == a:num
        let l:removed_tag_file = tag_file
        call remove(g:ctags_library_dicts[filetype],tag_file) 
        let l:filetype = filetype
        break
      endif
      let l:count += 1
    endfor
  endfor

  "remove tags
  let l:tags_dict = s:tags_dict()
  call filter(l:tags_dict, "v:key != l:removed_tag_file")
  call s:set_tags(l:tags_dict)

  "unapply 
  if !empty(l:filetype)
    call filter(g:ctags_library_applied, "v:key != filetype")
    call s:apply_library(l:filetype)
  endif

  call s:save_info_file()
endfunction

function! s:open_library(num, ishide)
  let l:count = 0
  for filetype in sort(keys(g:ctags_library_dicts))
    for tag_file in sort(keys(g:ctags_library_dicts[filetype]))
      if l:count == a:num
        execute("sp ". substitute(tag_file, " ", '\\ ', "g"))
        if a:ishide
          execute("hide")
        endif
        break
      endif
      let l:count += 1
    endfor
  endfor
endfunction

function! s:add_library(dir, filetype)
  let l:dirs ={}
  if !has_key(g:ctags_library_dicts, a:filetype)
    let g:ctags_library_dicts[a:filetype] = {}  
  endif
  let l:lib_dicts = g:ctags_library_dicts[a:filetype]

  if filereadable(a:dir . "/tags")
    let l:lib_dicts[a:dir . "/tags"]=1
  else
    let msg = "Din't find tags file. \nDo you make tags with '!ctags -R'? (y/n): "
    if input(msg) == "y"
      let old = getcwd()
      execute("chdir " . escape(a:dir, " \"'"))
      execute("!ctags -R")
      execute("chdir " . escape(old, " \"'"))
      let l:lib_dicts[a:dir . "/tags"]=1
    endif
  endif

  call s:save_info_file()
  call filter(g:ctags_library_applied, "v:key != a:filetype")
endfunction


function! s:manage_library(...) 
  if a:0 == 0
    echo "CTLibrary command"
    echo "  add    : add target dir to library path.(usage: add [dir] [filetype])"
    echo "  remove : remove library paths.          (usage: remove {n}|all"
    echo "           {n} : index"
    echo "  show   : show library paths"
    echo "  apply  : apply library by {filetype}.   (usage: apply {filetype})"
    echo "  unapply: unapply library by {filetype}. (usage: apply {filetype})"
    echo "  open   : open library tag file.         (usage: open  {n})"
    echo "  hide   : open and hide library tag file.(usage: hide  {n})"
    echo "  "
  else
    if a:1 == "add"
      let l:dir = a:0 >= 1 ? getcwd() : a:2
      let l:dir = l:dir == "." ? getcwd() : l:dir
      let l:filetype = a:0 == 3 ? a:3 : "all"

      call s:add_library(l:dir, l:filetype)
      if has_key(g:ctags_library_applied, l:filetype)
        call s:unapply_library(l:filetype)
        call s:apply_library(l:filetype)
      endif
    elseif a:1 == "remove"
      call s:remove_library(str2nr(a:2))
    elseif a:1 == "open"
      call s:open_library(str2nr(a:2), 0)
      return
    elseif a:1 == "hide"
      call s:open_library(str2nr(a:2), 1)
      return
    elseif a:1 == "show"
    elseif a:1 == "apply" && a:0 == 2
      call s:apply_library(a:2)
    elseif a:1 == "unapply" && a:0 == 2
      call s:unapply_library(a:2)
    endif
  endif
  call s:show_library()
endfunction
" }}}1

" update current file to tags after saving{{{1
function! s:update_ctags(tag_dir, target_file)
  let l:current_dir = getcwd()
  execute("chdir " . escape(a:tag_dir, " \"'"))
  call system("ctags --append=yes " . escape(a:target_file, " \"'"))
  execute("chdir " . escape(l:current_dir, " \"'"))
endfunction

function! s:update_current_to_related_tags()
  let l:current_file = expand("%:p")
  let l:levels = insert(split(expand("%:p:h"),s:separator()), "1")

  let l:tag_dir = "." . s:separator()
  for level in l:levels
    if filereadable(l:tag_dir . s:separator() . "tags")
      call s:update_ctags(l:tag_dir, l:current_file)
    endif
    let l:tag_dir = l:tag_dir . ".." . s:separator()
  endfor
endfunction

" }}}1

" define command {{{1
command! -nargs=* -bar CTProject call s:manage_project(<f-args>)
command! -nargs=* -bar CTLibrary call s:manage_library(<f-args>)
" }}}1

" Event bind {{{1
function! s:onBufWinEnter()
  call s:apply_library(&filetype)
endfunction

function! s:onBufWritePost()
  call s:update_current_to_related_tags();
endfunction

augroup  ctag_helper_group
autocmd! ctag_helper_group
autocmd  ctag_helper_group BufWinEnter * silent! call s:onBufWinEnter()
autocmd  ctag_helper_group BufWritePost * silent! call s:onBufWritePost()

" }}}1

" vim: set fdm=marker:
