if !exists("g:tr_size")      | let g:tr_size      = 15 | endif
if !exists("g:tr_vert_size") | let g:tr_vert_size = 80 | endif
if !exists("g:tr_cmd")       | let g:tr_cmd       = "" | endif
if !exists("g:tr_write_cmd") | let g:tr_write_cmd = "" | endif

function! s:smart_split()
    if winwidth("%") / 2 > 80
        execute "vnew | resize " . g:tr_vert_size . " | set bufhidden=delete"
    else
        execute "new  | resize " . g:tr_size      . " | set bufhidden=delete"
    endif
endfunction

function! s:term_exit(job_id, data, event) dict
    unlet g:tr_job_id
    if bufexists(g:tr_buf_id)
        execute "bdelete! " . g:tr_buf_id
    endif
    unlet g:tr_buf_id
endfunction

function! termrun#term_start()
    call s:smart_split()
    let g:tr_job_id = termopen($SHELL, {"on_exit": function("s:term_exit")})
    let g:tr_buf_id = bufnr("$")
    wincmd p
endfunction

function! termrun#term_run(cmd)
    if a:cmd == "" | return | endif
    if !exists("g:tr_job_id") | call termrun#term_start() | endif
    call chansend(g:tr_job_id, [a:cmd, ""])
endfunction

function! termrun#term_stop()
    if exists("g:tr_job_id")
        call jobstop(g:tr_job_id)
    endif
endfunction

nnoremap <cr>      :call termrun#term_run(g:tr_cmd)<cr>
nnoremap <leader>r :let g:tr_cmd = ""<left>
nnoremap <leader>w :let g:tr_write_cmd = ""<left>

autocmd BufWritePost * call termrun#term_run(g:tr_write_cmd)
