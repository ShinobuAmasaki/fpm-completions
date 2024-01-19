![demo](https://github.com/ShinobuAmasaki/fpm-completions/assets/100006043/635de99f-e562-4d86-b05c-92697fe075f0)

# fpm-completions
Command-line completion functions for the Fortran Package Manager.

## Bash
This package provides a completion script for bash. 

To use the script `bash/fpm.bash`, Bash (v4.x, or newer) and bash-completion(v2.x, or newer) are required.

Put the `fpm.bash` file in the `bash/` directory into the directory `~/.local/share/bash-completion/completions`.

Then, reload the shell.
```shell
$ exec -l $SHELL
```

## Zsh

This package also provides a completion script for Zsh.

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
