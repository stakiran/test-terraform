# test-terraform
Terraform の練習

- null_resource で tf language 練習中

## あとで for_each に変えた時に差分をなくす（ための state mv？を試してみたい）
まずはAさんとBさんをハードコードでつくる

```json
  "resources": [
    {
      "mode": "managed",
      "type": "null_resource",
      "name": "A",
      "provider": "provider[\"registry.terraform.io/hashicorp/null\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "8226512072947532812",
            "triggers": {
              "age": "13",
              "name": "Aさん"
            }
          },
          "sensitive_attributes": [],
          "private": "bnVsbA=="
        }
      ]
    },
```

これを for_each で作り直す。

元コードそのままでつくって、plan したところまで

```tf
variable users {
  default = {
    A = {
      age = 13
    }
    B = {
      age = 26
    }
  }
}

resource "null_resource" "user" {
  for_each = var.users

  triggers = {
    name = "${each.key}さん"
    age  = each.value.age
  }
}
```

```
Terraform will perform the following actions:

  # null_resource.user["A"] will be created
  + resource "null_resource" "user" {
      + id       = (known after apply)
      + triggers = {
          + "age"  = "13"
          + "name" = "Aさん"
        }
    }

  # null_resource.user["B"] will be created
  + resource "null_resource" "user" {
      + id       = (known after apply)
      + triggers = {
          + "age"  = "26"
          + "name" = "Bさん"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

元コードを消す

```
  # null_resource.A will be destroyed
  - resource "null_resource" "A" {
      - id       = "8226512072947532812" -> null
      - triggers = {
          - "age"  = "13"
          - "name" = "Aさん"
        } -> null
    }

  # null_resource.B will be destroyed
  - resource "null_resource" "B" {
      - id       = "2700166427688578824" -> null
      - triggers = {
          - "age"  = "26"
          - "name" = "Bさん"
        } -> null
    }
……
Plan: 2 to add, 0 to change, 2 to destroy.
```

ここで本題。

この差分を消すためには、何をすればいい？

- state mv？
- tfstate 直編集？

state mv 調べてみる

## ===

## variebla 空定義の謎
必要性がわからないので調べる

何も指定していないとこうなる

```
Error: Reference to undeclared input variable

  on main.tf line 7, in resource "null_resource" "person":
   7:     name = var.name

An input variable with the name "name" has not been declared. This variable
can be declared with a variable "name" {} block.
```

var-file=config1.tfvars すると、以下警告が出る

```
$ tf plan -var-file=config1.tfvars

Warning: Value for undeclared variable

The root module does not declare a variable named "age" but a value was found
in file "config1.tfvars". To use this value, add a "variable" block to the
configuration.
```

そもそも tfvars について知らないから、まずは見てみよう。

- https://www.terraform.io/docs/language/values/variables.html#assigning-values-to-root-module-variables
- なるほど、input variable に値を投入する手段の一つが「tfvars」、という位置づけ
- input variable ありき

variable の定義を main.tf に書くか、別のファイルに書くか

- どっちでもいける
- variables.tf に分けて書いてみた

## ===

## count meta-argument による ifdef 練習したり、tfvars 使ってみたり
tfvars:

- tfvars ファイル
    - varname = value 形式で書く
- 参照
    - var.xxxx
- ただし `variable VARNAME{...}` で宣言が必要

実行

```
$ tf plan -var-file=asan.tfvars
```

count は見にくいので、locals でリーダブルにすると良い？（好みわかれそうだけど。。。

## locals で block どこまでネストできるか
特に三重以上もできるか試したい。

できます。

```tf
locals {
  personal = {
    preferences = {
      name = "Apple"
    }
  }
}

resource "null_resource" "fruit" {
  triggers = {
    name  = local.personal.preferences.name
    color = "Red"
    price = 150
  }
}
```

## q: jpname, color, price を持つテンプレートをつくって apple, lemon, melon をつくる
まとめ

- module 使う
- module を新しく定義する度に tf init が必要
- module xxx 内でリソースをつくる場合の resource name
    - :x: input var から与えてもらう
    - :o: 適当に固定する
    - 識別子は呼び出し元の `module "ここ" {……}` で判断される
- 呼び出し元からデータにアクセスしたい場合, module 側で output しておくこと
    - js でいう export

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

↑ ~~なんでダメ？~~ output で返しなさい.

できた

```
$ tf output
var1 = "りんご"

$ tf state list
module.apple.null_resource.fruit
module.lemon.null_resource.fruit
```

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
