# test-terraform
Terraform の練習

- null_resource で tf language 練習中

## q: jpname, color, price を持つテンプレートをつくって apple, lemon, melon をつくる

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
