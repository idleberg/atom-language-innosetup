# Inno Setup for Atom

[![apm](https://img.shields.io/apm/l/language-innosetup.svg?style=flat-square)](https://atom.io/packages/language-innosetup)
[![apm](https://img.shields.io/apm/v/language-innosetup.svg?style=flat-square)](https://atom.io/packages/language-innosetup)
[![apm](https://img.shields.io/apm/dm/language-innosetup.svg?style=flat-square)](https://atom.io/packages/language-innosetup)
[![Travis](https://img.shields.io/travis/idleberg/atom-language-innosetup.svg?style=flat-square)](https://travis-ci.org/idleberg/atom-language-innosetup)
[![David](https://img.shields.io/david/dev/idleberg/atom-language-innosetup.svg?style=flat-square)](https://david-dm.org/idleberg/atom-language-innosetup?type=dev)

Atom language support for [Inno Setup](https://github.com/jrsoftware/issrc), including grammar, snippets and build system

![Screenshot](https://raw.githubusercontent.com/idleberg/atom-language-innosetup/master/screenshot.png)

*Screenshot of Inno Setup in Atom with [Hopscotch](https://atom.io/themes/hopscotch) theme*

## Installation

### apm

Install `language-innosetup` from Atom's [Package Manager](http://flight-manual.atom.io/using-atom/sections/atom-packages/) or the command-line equivalent:

`$ apm install language-innosetup`

### Using Git

Change to your Atom packages directory:

```bash
# Windows
$ cd %USERPROFILE%\.atom\packages

# Linux & macOS
$ cd ~/.atom/packages/
```

Clone repository as `language-innosetup`:

```bash
$ git clone https://github.com/idleberg/atom-language-innosetup language-innosetup
```

### Package Dependencies

This package automatically installs third-party packages it depends on. You can prevent this by disabling the *Manage Dependencies* option in the package settings.

## Usage

### Building

As of recently, this package contains a build system to compile Inno Setup scripts. But first, make sure `ISCC.exe` is in your [PATH environmental variable](http://superuser.com/a/284351/195953). Alternatively, you can specify its path in your Atom [configuration](http://flight-manual.atom.io/using-atom/sections/basic-customization/#_global_configuration_settings).

**Example:**

```cson
"language-innosetup":
  pathToISCC: "full\\path\\to\\ISCC.exe"
```

**Note**: If you're on macOS or Linux and would like to compile scripts with Wine, specify the path to this [bash script](https://gist.github.com/idleberg/4242e688ffe494e90a08bc4e83fe2b63) instead.

To compile your scripts, select *Inno Setup: Save & Compile”* from the [command-palette](https://atom.io/docs/latest/getting-started-atom-basics#command-palette) or use the keyboard shortcut.

#### Third-party packages

Should you prefer working with an existing third-party build system, the following packages already have support for Inno Setup.

* [build](https://atom.io/packages/build) – requires additional provider (e.g. [build-innosetup](https://atom.io/packages/build-innosetup)), supports [linter](https://atom.io/packages/linter)
* [script](https://atom.io/packages/script)

## License

This work is licensed under the [The MIT License](LICENSE.md).
