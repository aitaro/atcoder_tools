# AtcoderTools
Atcoderの競技環境を簡単にsetupするためのツールです。現在過去問のみ対応しています。

## インストール
```bash
$ gem install atcoder_tools
```

## 使い方
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
$ atcoder_tools submit abc170
```

### コンテストの削除
```
$ atcoder_tools delete abc170
```

### MODEについて
- NONE: なにもおこらない
- DEBUG: 標準入力で、testcaseが渡されたら状態で実行される。
- RUN: 単純にファイルを実行。標準入力は自分で渡す。
- TEST: rspecを用いたテスト自動実行。どれが通っていてどれが通っていないかわかる。

## Development
本リポジトリをクローンし、path指定して、gemをインストールするとデバッグできる。

## Contributing
issueやプルリク適当に投げてくれてかまいません。

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct
Everyone interacting in the AtcoderTools project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/atcoder_tools/blob/master/CODE_OF_CONDUCT.md).
