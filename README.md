# fpm-completions
Command-line completion functions for the Fortran Package Manager.

## Zsh

Zsh is required to use this package, currently.

Place the `_zsh` file in the `zsh/` directory in the directory described in the shell variable `fpath`.

Furthermore, add the following to `~/.zshrc`:
```shell
autoload -Uz compinit
compinit -u
```

Finally, reload the shell.
```
% exec -l $SHELL
```

or,

```shell 
unfunction _fpm && autoload -U _fpm
```

For example, if you place the `_zsh` file in `~/zsh/functions`, the `~/.zshrc` will be like this:

```shell
fpath=( "$HOME/zsh/functions" "${fpath[@]}" )
autoload -Uz compinit
compinit -u
```

Don't forget to reload the shell. 
```shell
% exec -l $SHELL
```
