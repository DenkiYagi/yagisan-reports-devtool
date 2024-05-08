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
npx yagisan yrt pack <xml>

Create a YRT file from a XML file and any assets.

Positionals:
  xml  XML file path                                         [string] [required]

Options:
  -A, --asset    Append asset (usage: `--asset /path/to/aseet@id`)       [array]
  -O, --out                                                             [string]
```
