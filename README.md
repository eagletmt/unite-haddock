# unite-haddock

[unite.vim](https://github.com/Shougo/unite.vim) source for haddock and hoogle

## Usage
`:Unite haddock` shows all installed modules.

`:Unite hoogle` shows the result of hoogle command.
You have to install the hoogle command by `cabal install hoogle` to enable this source.

## Actions

### browse\_local (default)
Opens local haddock.

- Note: To generate local documentations, you must install packages with `--enable-documentation`, or edit $HOME/.cabal/config: `documentation: True`.

### browse\_remote
Opens remote haddock (Hackage)

## Global Variables

### g:unite\_source\_haddock\_browser
The browser used to view documentations.

Normally, you don't have to set this variable.
If you uses a minor DE (e.g. awesome) and `xdg-open` fails to recognize local file URIs correctly, set this variable manually in your `~/.vimrc`.

~~~vim
let g:unite_source_haddock_browser = 'firefox'
~~~
