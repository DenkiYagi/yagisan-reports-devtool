# yagisan-reports-devtool

yagisan-reports-devtool は yagisan-reports の開発をするためのツールです。

現時点では帳票テンプレートを作成するには本ツールの使用が必須です。

## インストール

```
npm install -D https://github.com/DenkiYagi/yagisan-reports-devtool
```

## リファレンス

### yrtファイルの作成 : `yrt pack`

```sh
yagisan yrt pack <xml...>

Create a YRT file from an XML file and any assets

Positionals:
  xml  XML file (usage: `/path/to/xml` or `/path/to/xml@name`)
                                                [array] [required] [default: []]

Options:
      --help     Show help                                             [boolean]
      --version  Show version number                                   [boolean]
  -A, --asset    Append asset file (usage: `--asset /path/to/aseet@name`)[array]
  -S, --style    Append style xml file (usage: `--style /path/to/style`)[string]
  -O, --out      Set output file path                        [string] [required]
```

### 旧型式のyrtファイルの作成 : `yrt pack-alpha`

yagisan-reports v1.0.0-alpha.13 以前のバージョン用のyrtファイルを作成する場合は、こちらのコマンドを使用してください。

```sh
yagisan yrt pack-alpha <xml>

Create a YRT file from an XML file and any assets (legacy format for <= v1.0.0-alpha.13)

Positionals:
  xml  XML file path                                         [string] [required]

Options:
      --help     Show help                                             [boolean]
      --version  Show version number                                   [boolean]
  -A, --asset    Append asset (usage: `--asset /path/to/aseet@id`)       [array]
  -O, --out      Set output file path                                   [string]
```
