<div align="center">

# asdf-tbls [![Build](https://github.com/xcapaldi/asdf-tbls/actions/workflows/build.yml/badge.svg)](https://github.com/xcapaldi/asdf-tbls/actions/workflows/build.yml) [![Lint](https://github.com/xcapaldi/asdf-tbls/actions/workflows/lint.yml/badge.svg)](https://github.com/xcapaldi/asdf-tbls/actions/workflows/lint.yml)

[tbls](https://github.com/k1LoW/tbls) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `unzip` (required for macOS installations)

# Install

Plugin:

```shell
asdf plugin add tbls https://github.com/xcapaldi/asdf-tbls.git
```

tbls:

```shell
# Show all installable versions
asdf list-all tbls

# Install specific version
asdf install tbls latest

# Set a version globally (on your ~/.tool-versions file)
asdf global tbls latest

# Now tbls commands are available
tbls version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/xcapaldi/asdf-tbls/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Xavier Capaldi](https://github.com/xcapaldi/)
