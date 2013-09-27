function! unite#sources#haddock#define()
  if executable('ghc-pkg')
    return s:source
  else
    return []
  endif
endfunction

let s:source = { 'name': 'haddock' }

function! s:get_modules()
  let l:mods = []
  for l:line in split(unite#haddock#ghc_pkg("field '*' exposed-modules"), '\n')
    let l:line = substitute(l:line, '^exposed-modules:', '', '')
    let l:line = substitute(l:line, '^\s\+', '', '')
    call extend(l:mods, split(l:line, ' '))
  endfor
  call sort(l:mods)
  return l:mods
endfunction

function! s:source.gather_candidates(args, context)
  let l:mods = s:get_modules()
  return map(l:mods, '{ "word": v:val, "source": "haddock", "kind": "haddock", "action__haddock_module": v:val }')
endfunction
