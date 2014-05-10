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
      \ }

function! s:source.gather_candidates(args, context)
  let l:exact = !empty(filter(copy(a:args), 'v:val ==# "exact"'))
  let l:output = unite#util#system(printf('hoogle search --verbose --link --count %d %s%s', s:max_candidates(), s:exact_flag(l:exact), shellescape(a:context.input)))
  if unite#util#get_last_status() == 0
    let l:candidates = map(split(s:remove_verbose(l:output, 0), '\n'), 's:make_candidate(a:context.input, v:key, v:val, l:exact)')
    return filter(l:candidates, '!empty(v:val.action__haddock_module)')
  else
    return []
  endif
endfunction

function! s:make_candidate(input, index, line, exact)
  let l:line = matchstr(a:line, '^.\+\ze -- \(\(http\|file\)://\)\?')
  let l:candidate = {
        \ 'word': a:input,
        \ 'abbr': l:line,
        \ 'source': 'hoogle',
        \ 'kind': 'haddock',
        \ 'action__haddock_module': '',
        \ 'action__haddock_fragment': '',
        \ 'action__haddock_index': a:index,
        \ 'action__haddock_exact': a:exact,
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
  let l:exact = s:exact_flag(a:candidate.action__haddock_exact)
  let l:query = shellescape(a:candidate.word)
  let l:output = unite#util#system(printf('hoogle search --verbose --info --start %d %s%s', l:start, l:exact, l:query))
  silent pedit! hoogle
  wincmd P
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal syntax=none
  setlocal bufhidden=delete
  silent put = s:remove_verbose(l:output, 1)
  silent 1 delete _
  wincmd p
  redraw!
endfunction

function! s:exact_flag(exact)
  return a:exact ? '--exact ' : ''
endfunction

function! s:remove_verbose(output, once)
  let l:output = substitute(a:output, '^.*= ANSWERS =\n', '', '')
  let l:output = substitute(l:output, '^No results found\n', '', '')
  let l:output = substitute(l:output, '  -- \(\a\+\(+\a\+\)*\)*', '', a:once ? '' : 'g')
  return l:output
endfunction

