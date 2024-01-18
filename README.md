![demo](https://github.com/ShinobuAmasaki/fpm-completions/assets/100006043/635de99f-e562-4d86-b05c-92697fe075f0)

# fpm-completions
Command-line completion functions for the Fortran Package Manager.

## Zsh

Zsh is required to use this package, currently.

Put the `_zsh` file in the `zsh/` directory into the directory described in the shell variable `fpath`.

Furthermore, add the following to `~/.zshrc`:
```shell
autoload -Uz compinit
compinit -u
```

Finally, reload the shell.
```shell
% exec -l $SHELL
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
