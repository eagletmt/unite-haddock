function! unite#sources#hoogle#define()
  if executable('hoogle')
    return s:source
  else
    return []
  endif
endfunction

let s:source = {
      \ 'name': 'hoogle',
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 1,
      \ 'action_table': {'*': {}},
      \ 'hooks': {},
      \ }

function! s:source.gather_candidates(args, context)
  let l:output = unite#util#system(printf('hoogle search --link --count %d %s%s', s:max_candidates(), s:exact, shellescape(a:context.input)))
  if unite#util#get_last_status() == 0
    return map(split(l:output, '\n'), 's:parse(a:context.input, v:key, v:val)')
  else
    return []
  endif
endfunction

function! s:parse(input, index, line)
  let l:line = matchstr(a:line, '^.\+\ze -- http://')
  let l:candidate = {
        \ 'word': a:input,
        \ 'abbr': l:line,
        \ 'source': 'hoogle',
        \ 'kind': 'haddock',
        \ 'action__haddock_module': '',
        \ 'action__haddock_fragment': '',
        \ 'action__haddock_index': 1,
        \ }
  let l:m = matchlist(a:line, '^\(\S\+\)\s\+\(\S\+\)\(.*\)$')
  if empty(l:m)
    return l:candidate
  endif

  let [l:mod, l:sym, l:rest] = l:m[1 : 3]
  if l:mod ==# 'package'
    return l:candidate
  else
    let l:candidate.action__haddock_module = l:mod
    let l:candidate.action__haddock_fragment = matchstr(l:rest, '#.\+$')
    let l:candidate.action__haddock_index = a:index
    return l:candidate
  endif
endfunction

function! s:max_candidates()
  return get(g:, 'unite_source_hoogle_max_candidates', 200)
endfunction

let s:source.action_table['*'].preview = {
      \ 'description': 'preview information',
      \ 'is_quit': 0,
      \ }

function! s:source.action_table['*'].preview.func(candidate)
  let l:start = a:candidate.action__haddock_index + 1
  let l:query = shellescape(a:candidate.word)
  let l:output = unite#util#system(printf('hoogle search --info --start %d %s%s', l:start, s:exact, l:query))
  silent pedit! hoogle
  wincmd P
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal syntax=none
  setlocal bufhidden=delete
  silent put = l:output
  silent 1 delete _
  wincmd p
  redraw!
endfunction

function! s:source.hooks.on_init(args, context)
  let s:exact = !empty(filter(copy(a:args), 'v:val ==# "exact"')) ? '--exact ' : ''
endfunction

function! s:source.hooks.on_close(args, context)
  unlet s:exact
endfunction
