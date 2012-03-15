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
    let l:mod = l:candidate.word
    let l:pkg = s:find_pkg(l:mod)
    let l:output = unite#util#system('ghc-pkg field ' . l:pkg . ' haddock-html')
    let l:dir = matchstr(substitute(l:output, '\n', ' ', 'g'), 'haddock-html: \zs\S\+\ze')
    let l:path = printf('%s/%s.html', l:dir, substitute(l:mod, '\.', '-', 'g'))
    if filereadable(l:path)
      call unite#take_action('start', extend(deepcopy(l:candidate), { 'action__path': 'file://' . l:path }))
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
    let l:mod = l:candidate.word
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
    call unite#take_action('start', extend(deepcopy(l:candidate), { 'action__path': l:path }))
  endfor
endfunction

function! s:find_pkg(mod)
  let l:output = unite#util#system('ghc-pkg find-module --simple-output ' . a:mod)
  return matchstr(get(split(l:output, '\n'), 0), '^\S\+')
endfunction
