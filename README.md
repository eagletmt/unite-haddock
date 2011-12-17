# unite-haddock

[unite.vim](https://github.com/Shougo/unite.vim) source for haddock

## Requirements

- ghc-mod
  - `cabal install ghc-mod`
  - Make sure $PATH contains the Cabal's bindir (normally $HOME/.cabal/bin).

## Usage
`:Unite haddock` shows all installed modules.

## Actions

### browse\_local (default)
Opens local haddock.

- Note: To generate local documentations, you must install packages with `--enable-documentation`, or edit $HOME/.cabal/config: `documentation: True`.

### browse\_remote
Opens remote haddock (Hackage)
