function! unite#sources#haddock#define()
  if executable('ghc-mod') && executable('ghc-pkg')
    return s:source
  else
    return []
  endif
endfunction

let s:source = {
      \ 'name': 'haddock',
      \ 'action_table': {},
      \ 'default_action': 'browse_local',
      \ }

function! s:source.gather_candidates(args, context)
  let l:mods = split(unite#util#system('ghc-mod list'), '\n')
  return map(l:mods, '{ "word": v:val, "source": "haddock", "kind": "uri" }')
endfunction

function! s:find_pkg(mod)
  let l:output = unite#util#system('ghc-pkg find-module --simple-output ' . a:mod)
  return matchstr(get(split(l:output, '\n'), 0), '^\S\+')
endfunction

let s:source.action_table.browse_local = {
      \ 'description': 'open local haddock',
      \ }
function! s:source.action_table.browse_local.func(candidate)
  let l:mod = a:candidate.word
  let l:pkg = s:find_pkg(l:mod)
  let l:output = unite#util#system('ghc-pkg field ' . l:pkg . ' haddock-html')
  let l:dir = matchstr(substitute(l:output, '\n', ' ', 'g'), 'haddock-html: \zs\S\+\ze')
  let l:path = printf('%s/%s.html', l:dir, substitute(l:mod, '\.', '-', 'g'))
  if filereadable(l:path)
    call unite#take_action('start', extend(deepcopy(a:candidate), { 'action__path': 'file://' . l:path }))
  else
    call unite#util#print_error(printf("documentation for '%s' (%s) does not exist", l:mod, l:pkg))
  endif
endfunction

let s:source.action_table.browse_remote = {
      \ 'description': 'open remote haddock (Hackage)',
      \ }
function! s:source.action_table.browse_remote.func(candidate)
  let l:mod = a:candidate.word
  let l:pkg = s:find_pkg(l:mod)
  let l:m = matchlist(l:pkg, '^\([^-]\+\)-\(.\+\)$')
  let l:name = l:m[1]
  let l:ver = l:m[2]
  if l:name ==# 'ghc'
    let l:path = printf('http://www.haskell.org/ghc/docs/%s/html/libraries/ghc-%s/%s.html', l:ver, l:ver, substitute(l:mod, '\.', '-', 'g'))
  else
    let l:path = printf('http://hackage.haskell.org/packages/archive/%s/%s/doc/html/%s.html', l:name, l:ver, substitute(l:mod, '\.', '-', 'g'))
  endif
  call unite#take_action('start', extend(deepcopy(a:candidate), { 'action__path': l:path }))
endfunction
