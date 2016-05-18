# Inno Setup for Atom

[![apm](https://img.shields.io/apm/l/language-inno.svg?style=flat-square)](https://atom.io/packages/language-inno)
[![apm](https://img.shields.io/apm/v/language-inno.svg?style=flat-square)](https://atom.io/packages/language-inno)
[![apm](https://img.shields.io/apm/dm/language-inno.svg?style=flat-square)](https://atom.io/packages/language-inno)
[![Travis](https://img.shields.io/travis/idleberg/atom-language-inno.svg?style=flat-square)](https://travis-ci.org/idleberg/atom-language-inno)
[![David](https://img.shields.io/david/dev/idleberg/atom-language-inno.svg?style=flat-square)](https://david-dm.org/idleberg/atom-language-inno#info=devDependencies)

Atom language support for [Inno Setup](https://github.com/jrsoftware/issrc), including grammar, snippets and a rudimentary build system

## Installation

### apm

Install `language-inno` from Atom's [Package Manager](http://flight-manual.atom.io/using-atom/sections/atom-packages/) or the command-line equivalent:

`$ apm install language-inno`

### GitHub

Change to your Atom packages directory:

```bash
# Windows
$ cd %USERPROFILE%\.atom\packages

# Mac OS X & Linux
$ cd ~/.atom/packages/
```

Clone repository as `language-inno`:

`$ git clone https://github.com/idleberg/atom-language-inno language-inno`

## Usage

### Building

As of recently, this package contains a rudimentary build system to compile Inno Setup scripts. But first, make sure `ISCC.exe` is in your [PATH environmental variable](http://superuser.com/a/284351/195953). Alternatively, you can specify its path in your `config.cson`.

**Example:**

```cson
"language-inno":
  pathToISCC: "/full/path/to/ISCC.exe"
```

To compile your scripts, select *Inno Setup: Save & Compile”* from the [command-palette](https://atom.io/docs/latest/getting-started-atom-basics#command-palette) or use the keyboard shortcut.

#### Third-party packages

Should you already use the [build](https://atom.io/packages/build) package, you can install the [build-innosetup](https://atom.io/packages/build-innosetup) provider to build your code.

## License

This work is licensed under the [The MIT License](LICENSE.md).

## Donate

You are welcome support this project using [Flattr](https://flattr.com/submit/auto?user_id=idleberg&url=https://github.com/idleberg/atom-language-inno) or Bitcoin `17CXJuPsmhuTzFV2k4RKYwpEHVjskJktRd`