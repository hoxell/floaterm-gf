" Plugin to open file (and line number) in a normal window from within floaterm
if exists("g:loaded_floaterm_gf")
    finish
endif
let g:loaded_floaterm_gf = 1

function! s:openInNormalWindow() abort
    const l:file = findfile(expand('<cfile>'))
    if !empty(l:file)
        FloatermHide
        execute 'e ' .. l:file
    endif
endfunction

function! s:openInNormalWindowGoToLine() abort
    try
        const l:original_wildignore = &wildignore
        set wildignore=
        const l:candidate_file = expand(expand('<cWORD>'))
    finally
        let &wildignore = l:original_wildignore
    endtry

    const [l:file_name, _, l:file_end] = matchstrpos(l:candidate_file, '\f\+')
    const l:file = findfile(l:file_name)
    if !empty(l:file)
        FloatermHide
        exec 'e ' .. l:file_name
    else
        return
    endif

    const [l:line_number, __, l:line_number_end] = matchstrpos(l:candidate_file, '\d\+', l:file_end + 1)
    if l:line_number == ''
        return
    endif

    const l:column_number = matchstr(l:candidate_file, '\d\+', l:line_number_end + 1)
    call cursor(l:line_number, l:column_number ? l:column_number : 0)
endfunction

augroup floaterm_gf
    au!
    autocmd FileType floaterm if !hasmapto('<Plug>FloatermGotoFile;') | nnoremap <unique> <buffer> gf <Plug>FloatermGotoFile;| endif | nnoremap <silent> <buffer>  <Plug>FloatermGotoFile; :call <SID>openInNormalWindow()<CR>
    autocmd FileType floaterm if !hasmapto('<Plug>FloatermGotoFileAndLine;') | nnoremap <unique> <buffer> gF <Plug>FloatermGotoFileAndLine;| endif | nnoremap <silent> <buffer> <Plug>FloatermGotoFileAndLine; :call <SID>openInNormalWindowGoToLine()<CR>
augroup END
