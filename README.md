# xwatch-ss

授業時間中に授業と関係ないサイトをブラウズしている等の学生端末に警告を表示する。
watch-ssの改良版。コマンド名 xwatch-ss は再考の余地あり。

## BUG

* 2016-09-29 逆引きがタイムアウトするとき。

## TODO

* xwatch-ss プロセスは1個以上、起動しないように。
* druby://ucome に投げ、ucome に処理させる。
* 着席状況チェック以外でも利用できるよう、seats の抽象化レベルを上げる必要あり。

## 仕組み

コマンド ss の出力を allow(permit) パターンでフィルタし、
フィルタをすり抜けた ESTAB なソケットの数が閾値を超えたら xcowsay を呼び出し警告する。

## xcowsay の利用

JOptionPane.showMessageDialog だと OK を押させてブロック解除しないといけない。
勝手に消える xcowsay はメリット大きい。


---
2016-09-23, 2016-09-29.
