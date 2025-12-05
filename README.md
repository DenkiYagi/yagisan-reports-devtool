# yagisan-reports-devtool

yagisan-reports-devtool は yagisan-reports の開発をするためのツールです。

現時点では帳票テンプレートを作成するには本ツールが必要です。

## インストール

```sh
npm install -D https://github.com/DenkiYagi/yagisan-reports-devtool
```

## リファレンス

### 帳票テンプレートファイル（yrtファイル）の操作

#### yrtファイルの作成 : `yrt pack`

```sh
Usage: yagisan yrt pack [options] <xml...>

Create a YRT file from XML files and any assets

Arguments:
  xml                 XML file (usage: `/path/to/xml` or `/path/to/xml@name`)

Options:
  -A, --asset <file>  Append asset file (usage: `--asset /path/to/asset@name`)
  -S, --style <file>  Append style xml file (usage: `--style /path/to/style`)
  -O, --out <file>    Set output file path
  -h, --help          Display help for command
```

#### yrtファイルの展開 : `yrt unpack`

```sh
Usage: yagisan yrt unpack [options] <yrt>

Extract contents from a YRT file

Arguments:
  yrt                     YRT file path

Options:
  -D, --dest <directory>  Output directory (default: same as YRT file)
  -h, --help              Display help for command
```

### 旧型式の帳票テンプレートファイルの操作

yagisan-reports v1.0.0-alpha.13 以前のバージョン用のyrtファイルを操作する場合は、こちらのコマンドを使用してください。

#### yrtファイル（旧型式）の作成 : `yrt-alpha pack`

```sh
Usage: yagisan yrt-alpha pack [options] <xml>

Create a YRT file from an XML file and any assets

Arguments:
  xml                 XML file path

Options:
  -A, --asset <file>  Append asset (usage: `--asset /path/to/asset@name`)
  -O, --out <file>    Set output file path
  -h, --help          Display help for command
```

#### yrtファイル（旧型式）の展開 : `yrt-alpha unpack`

```sh
Usage: yagisan yrt unpack [options] <yrt>

Extract contents from a YRT file

Arguments:
  yrt                     YRT file path

Options:
  -D, --dest <directory>  Output directory (default: same as YRT file)
  -h, --help              Display help for command
```

### glyphdataファイルの生成 : `glyphdata generate`

```sh
Usage: yagisan glyphdata generate [options] <font>

Generate glyphdata from a font file

Arguments:
  font              Font file path

Options:
  -O, --out <file>  Set output file path
  -h, --help        Display help for command
```
