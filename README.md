# AtcoderTools
[![Publish Gem](https://github.com/aitaro/atcoder_tools/workflows/Publish%20Gem/badge.svg)](https://github.com/aitaro/atcoder_tools/actions?query=workflow%3A%22Publish+Gem%22)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Gem Version](https://badge.fury.io/rb/atcoder_tools.svg)](https://badge.fury.io/rb/atcoder_tools)
[![Code Climate](https://codeclimate.com/github/aitaro/atcoder_tools.png)](https://codeclimate.com/github/aitaro/atcoder_tools)

Atcoderの競技環境を簡単にsetupするためのツールです。
現在 rubyとc++に対応しています。

## インストール
```bash
$ gem install atcoder_tools
```

## 使い方
### 言語の変更
```
$ atcoder_tools language
```

### atcoderにログイン
```
$ atcoder_tools login
```
コマンドを実行すると、user_nameとpasswordの入力画面になります。

### コンテスト用ファイルの作成
```
$ atcoder_tools create abc170
```

### コンテスト用自動デバッグ
```
$ atcoder_tools start
```

### コンテストの提出
```
$ atcoder_tools submit
```

### コンテストの削除
```
$ atcoder_tools delete
```

### MODEについて
- NONE: なにもおこらない
- DEBUG: 標準入力で、testcaseが渡されたら状態で実行される。
- RUN: ファイルを実行。標準入力は自分で渡す。
- TEST: rspecを用いたテスト自動実行。どれが通っていてどれが通っていないかわかる。

## Development
本リポジトリをクローンし、path指定して、gemをインストールするとデバッグできる。

## Contributing
issueやプルリク適当に投げてくれてかまいません。

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct
Everyone interacting in the AtcoderTools project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/atcoder_tools/blob/master/CODE_OF_CONDUCT.md).
