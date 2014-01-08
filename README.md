# unite-haddock

[unite.vim](https://github.com/Shougo/unite.vim) source for haddock and hoogle

## Usage
`:Unite haddock` shows all installed modules.

`:Unite hoogle` shows the result of hoogle command.
You have to install the hoogle command by `cabal install hoogle` to enable this source.

`:Unite hoogle:exact` shows the result of hoogle _exact_ search.
It corresponds to passing `--exact` argument to hoogle.

## Actions

### browse\_local (default)
Opens local haddock.

- Note: To generate local documentations, you must install packages with `--enable-documentation`, or edit $HOME/.cabal/config: `documentation: True`.

### browse\_remote
Opens remote haddock (Hackage).

- Note: If you'd like to make this action default, add `call unite#custom_default_action('haddock', 'browse_remote')` to your vimrc. See `:help unite#custom_default_action()` for more detail.

### preview (hoogle only)
Shows the information in the preview window.

- Note: You can preview the informatin by pressing `p` key on a candidate.

## Global Variables

### g:unite\_source\_hoogle\_max\_candidates
The maximal number of candidates of hoogle.

Default: 200

### g:unite\_source\_haddock\_browser
The browser used to view documentations.

Normally, you don't have to set this variable.
If you're using a minor DE (e.g. awesome, XMonad) and `xdg-open` fails to recognize local file URIs correctly, set this variable manually in your `~/.vimrc`.

~~~vim
let g:unite_source_haddock_browser = 'firefox'
~~~
