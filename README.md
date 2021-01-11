# test-terraform
Terraform の練習

- null_resource で tf language 練習中

## q: jpname, color, price を持つテンプレートをつくって apple, lemon, melon をつくる
まとめ

- module を新しく定義する度に tf init が必要
- module xxx 内でリソースをつくる場合の resource name
    - :x: input var から与えてもらう
    - :o: 適当に固定する
    - 識別子は呼び出し元の `module "ここ" {……}` で判断される

以下は resource name は fruit で固定している、かわりに module.xxx の部分で区別できてる

```terminal
$ tf show
# module.apple.null_resource.fruit:
resource "null_resource" "fruit" {
    id       = "4806688549126870450"
    triggers = {
        "color"  = "red"
        "jpname" = "りんご"
        "price"  = "300"
    }
}


# module.lemon.null_resource.fruit:
resource "null_resource" "fruit" {
    id       = "673598002620859379"
    triggers = {
        "color"  = "yellow"
        "jpname" = "レモン"
        "price"  = "95"
    }
}
```

===

`newFruit('レモン', '黄色', 90)` こういう感じでつくれると思ってるんだけど。

- https://www.terraform.io/docs/configuration/functions/templatefile.html

たぶんこれだが書き方全くピンと来ない。

モジュールか？

```tf
resource "null_resource" "${var.resource_name}" { // ここで変数使うのどうやるん？
  triggers = {
    jpname = var.jpname
    color  = var.color
    price  = var.price
  }
}
```

[Can't use programmatic resource names · Issue #571 · hashicorp/terraform](https://github.com/hashicorp/terraform/issues/571)

そもそも resource name に変数名与えるのが間違いっぽい？なんで？それじゃ resourcetype.name1 と resourcetype.name2 をプログラマブルにつくるとかできなくない？

> The names in Terraform are just logical for the purposes of referring to them. You want to parameterize the values inside the resource, and not the name itself, so this is by design. Multiple environments are supported by using different variable and state files.

何言ってるかまだわからん。

```
$ tf state list
null_resource.apple
module.lemon.null_resource.fruit

$ tf show
# null_resource.apple:
resource "null_resource" "apple" {
    id       = "5200011022573936439"
    triggers = {
        "color"  = "red"
        "jpname" = "りんご"
        "price"  = "300"
    }
}


# module.lemon.null_resource.fruit:
resource "null_resource" "fruit" {
    id       = "673598002620859379"
    triggers = {
        "color"  = "yellow"
        "jpname" = "レモン"
        "price"  = "95"
    }
}
```

```
output "var1" {
  value = module.apple.null_resource.fruit.jpname
}
```

↑ なんでダメ？



## null_resource でデータを持つリソース的なもの

```tf
provider "null" {

}

resource "null_resource" "apple" {
  triggers = {
    jpname = "りんご"
    color  = "red"
    price  = 300
  }
}

output "var1" {
  value = null_resource.apple.triggers.color
}
```

```
$ tf output
var1 = "red"
```

## 情報取得

```tf
$ tf state list
null_resource.r1

$ tf show
# null_resource.r1:
resource "null_resource" "r1" {
    id = "6887813976935370061"
}
```
