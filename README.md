# powershell-config

[![GitHub Actions: test](https://github.com/kakkun61/powershell-config/workflows/test/badge.svg)](https://github.com/kakkun61/powershell-config/actions?query=workflow%3Atest) [![GitHub Actions: install](https://github.com/kakkun61/powershell-config/workflows/install/badge.svg)](https://github.com/kakkun61/powershell-config/actions?query=workflow%3Ainstall) [![GitHub Actions: lint](https://github.com/kakkun61/powershell-config/workflows/lint/badge.svg)](https://github.com/kakkun61/powershell-config/actions?query=workflow%3Alint) [![PowerShell Gallery](https://img.shields.io/powershellgallery/p/config.svg)](https://www.powershellgallery.com/packages/config/) [![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=GitHub)](https://github.com/sponsors/kakkun61)

This is a configuration module for PowerShell. This finds configuration files, read them and convert them to `Hashtable`s.

## Specifications

This module treats three types of configurations:

- local configuration
- user global configuration
- system global configuration

## Local configuration

A local configuration is named _`$appname`.yaml_ and located at the current working directory or its parents recursively.

## User global configuration

A user global configuration is named _config.yaml_ and located at _`$Env:APPDATA\$appname`_.

## System global configuration

A system global configuration is named _config.yaml_ and located at _`$Env:ProgramData\$appname`_.

## Overwriting

When the configurations have the same keys, upper ones overwrite.

For example there are following configurations:

```yaml
# local configuration
foo: foo

# user global configuration
bar: bar

# system global configuration
bar: buzz
```

you get:

```yaml
foo: foo
bar: bar
```

`bar: buzz` is overwritten.

# Examples

## Local configuration

When _.\foo.yaml_ is:

```yaml
foo: 1
bar: hello
buzz:
 - one
 - two
```

call:

```
> Get-Config foo

Name                           Value
----                           -----
bar                            hello
foo                            1
buzz                           {one, two}
```
