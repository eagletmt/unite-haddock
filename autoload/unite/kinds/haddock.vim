function! unite#kinds#haddock#define()
  return s:kind
endfunction

let s:kind = {
      \ 'name': 'haddock',
      \ 'default_action': 'browse_local',
      \ 'action_table': {},
      \ 'parents': ['uri'],
      \ }

let s:kind.action_table.browse_local = {
      \ 'description': 'open local haddock',
      \ 'is_selectable': 1,
      \ }
function! s:kind.action_table.browse_local.func(candidates)
  for l:candidate in a:candidates
    let l:mod = l:candidate.action__haddock_module
    if empty(l:mod)
      call unite#util#print_error(printf("No module is defined for '%s'", get(l:candidate, 'abbr', l:candidate.word)))
      continue
    endif
    let l:pkg = s:find_pkg(l:mod)
    let l:output = unite#haddock#ghc_pkg('field ' . l:pkg . ' haddock-html')
    let l:dir = matchstr(substitute(l:output, '\n', ' ', 'g'), 'haddock-html: \zs\S\+\ze')
    let l:path = printf('%s/%s.html', l:dir, substitute(l:mod, '\.', '-', 'g'))
    if filereadable(l:path)
      let l:path .= get(l:candidate, 'action__haddock_fragment', '')
      call s:browse(l:candidate, 'file://' . l:path)
    else
      call unite#util#print_error(printf("documentation for '%s' (%s) does not exist", l:mod, l:pkg))
    endif
  endfor
endfunction

let s:kind.action_table.browse_remote = {
      \ 'description': 'open remote haddock (Hackage)',
      \ 'is_selectable': 1,
      \ }
function! s:kind.action_table.browse_remote.func(candidates)
  for l:candidate in a:candidates
    let l:mod = l:candidate.action__haddock_module
    if empty(l:mod)
      call unite#util#print_error(printf("No module is defined for '%s'", get(l:candidate, 'abbr', l:candidate.word)))
      continue
    endif
    let l:pkg = s:find_pkg(l:mod)
    let l:m = matchlist(l:pkg, '^\(.\+\)-\([.0-9]\{-}\)$')
    let l:name = l:m[1]
    let l:ver = l:m[2]
    if l:name ==# 'ghc' || l:name ==# 'ghc-prim'
      if l:name ==# 'ghc'
        let l:ghc_ver = l:ver
      else
        let l:ghc_ver = unite#util#system('ghc --numeric-version')
      endif
      let l:path = printf('http://www.haskell.org/ghc/docs/%s/html/libraries/%s-%s/%s.html', l:ghc_ver, l:name, l:ver, substitute(l:mod, '\.', '-', 'g'))
    else
      let l:path = printf('http://hackage.haskell.org/packages/archive/%s/%s/doc/html/%s.html', l:name, l:ver, substitute(l:mod, '\.', '-', 'g'))
    endif
    let l:path .= get(l:candidate, 'action__haddock_fragment', '')
    call s:browse(l:candidate, l:path)
  endfor
endfunction

function! s:find_pkg(mod)
  let l:output = unite#haddock#ghc_pkg('find-module --simple-output ' . a:mod)
  return matchstr(get(split(l:output, '\n'), 0), '^\S\+')
endfunction

function! s:browse(candidate, uri)
  if exists('g:unite_source_haddock_browser')
    call unite#util#system(printf('%s %s &', g:unite_source_haddock_browser, shellescape(a:uri)))
  else
    call unite#take_action('start', extend(deepcopy(a:candidate), { 'action__path': a:uri }))
  endif
endfunction
