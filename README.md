# test-terraform
Terraform の練習

## tf 言語を試したい場合はどうすればいい？
- windows 版の terraform console は使いづらい
- xxx.tf 書いて、リソースつくらずに挙動だけ調べたい

tf output で、**applyされた** output variable の一覧を表示できる。

ってことは「試したい tf ファイルだけ apply させ」なきゃダメか。できる？

- [Terraform: apply only one tf file - DevOps Stack Exchange](https://devops.stackexchange.com/questions/4292/terraform-apply-only-one-tf-file)
- `terraform apply -target=★ここにリソース名を指定する`
    - `tf state list` で既存リソースを一覧表示できる

ダミーのリソースとか可能？ null resource 的な？

- [null_resources | Resources | hashicorp/null | Terraform Registry](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)


## 試す
[Provider: GitHub - Terraform by HashiCorp](https://www.terraform.io/docs/providers/github/index.html)

略したら `GITHUB_TOKEN` 環境変数見てくれるとのことなので、これ使う.

### 1 new

```
$ terraform init

$ terraform plan

$ terraform plan -put main.plan

$ terraform apply
……
Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

github_repository.test-from-terraform: Creating...
github_repository.test-from-terraform: Creation complete after 7s [id=test-from-terraform]
```

おおー、できてる。

- https://github.com/stakiran/test-from-terraform

```
$ terraform apply
github_repository.test-from-terraform: Refreshing state... [id=test-from-terraform]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

### 2 create file

```
github_repository_file.readme: Creating...

Error: Branch main not found in repository or repository is not readable

  on main.tf line 16, in resource "github_repository_file" "readme":
  16: resource "github_repository_file" "readme" {
```

先に進めん。何がおかしい？

- https://github.com/yuya-takeyama/terraform-multiple-providers-practice/blob/4315305f051aee0f04f7d6c4166085aa9b077f6b/main.tf
    - `repository = "test-from-terraform"` でも動かん
    - `repository = github_repository.repo.name` にしてるけど動かん
- branch は main でも master でもダメ
- github token の scope？
    - でも repo だよなぁ
    - delete repo は別にあったので追加したけど

https://github.com/terraform-providers/terraform-provider-github/blob/4c7264800e7d56e6faae976b44e63b37051082dc/github/resource_github_repository_file.go#L319

- `checkRepositoryBranchExists` func
- いやデフォは main ブランチですよねぇ？

auto_init true で初期化しないとダメ……ってことはないよなぁ

[Cannot set the default branch on a new repository · Issue #146 · terraform-providers/terraform-provider-github](https://github.com/terraform-providers/terraform-provider-github/issues/146)

- なんか API の仕様でブランチは master 使い給え、言うてますけど
- default_branch 使ったらリソースの方使え warning → 公式ドキュメントないですけど → ソース見る
    - [terraform-provider-github/resource_github_branch_default.go at master · terraform-providers/terraform-provider-github](https://github.com/terraform-providers/terraform-provider-github/blob/master/github/resource_github_branch_default.go)

> Error: PATCH https://api.github.com/repos/stakiran/test-from-terraform: 422 Validation Failed [{Resource:Repository Field:default_branch Code:invalid Message:Cannot update default branch for an empty repository. Please init the repository and push first.}]

どういうこと？ push first ってあるけど、file 追加しようとすると branch not found が出て、上記 issue によると main じゃなく master を使うべきで……堂々巡りなんだが :confused:

default branch 問題じゃないっぽい。じゃあなんだろう。

GitHub のソース漁ってる [Search · resource "github_repository_file"](https://github.com/search?q=resource+%22github_repository_file%22&type=code) けど、やっぱりこれで通らないのおかしいって。なぜだ。

token しか考えられん。でもないけどなー、repo create みたいな scope。repo ちゃうん？

debug log 有効にしてみた

```
2020-12-21T20:46:37.108+0900 [DEBUG] plugin.terraform.exe: X-Oauth-Scopes: delete_repo, repo, write:discussion ★これで足りてる？
2020-12-21T20:46:37.108+0900 [DEBUG] plugin.terraform.exe: X-Ratelimit-Limit: 5000
2020-12-21T20:46:37.108+0900 [DEBUG] plugin.terraform.exe: X-Ratelimit-Remaining: 4997 ★このへんは問題ないよな
2020-12-21T20:46:37.108+0900 [DEBUG] plugin.terraform.exe: X-Ratelimit-Reset: 1608554791
2020-12-21T20:46:37.108+0900 [DEBUG] plugin.terraform.exe: X-Ratelimit-Used: 3
2020-12-21T20:46:37.108+0900 [DEBUG] plugin.terraform.exe: X-Xss-Protection: 1; mode=block
2020-12-21T20:46:37.108+0900 [DEBUG] plugin.terraform.exe:
2020-12-21T20:46:37.108+0900 [DEBUG] plugin.terraform.exe: 6e
2020-12-21T20:46:37.109+0900 [DEBUG] plugin.terraform.exe: {
2020-12-21T20:46:37.109+0900 [DEBUG] plugin.terraform.exe:  "message": "Branch not found", ★なんでや……
2020-12-21T20:46:37.109+0900 [DEBUG] plugin.terraform.exe:  "documentation_url": "https://docs.github.com/rest/reference/repos#get-a-branch"
2020-12-21T20:46:37.109+0900 [DEBUG] plugin.terraform.exe: }
2020-12-21T20:46:37.109+0900 [DEBUG] plugin.terraform.exe: 0
2020-12-21T20:46:37.109+0900 [DEBUG] plugin.terraform.exe:
2020-12-21T20:46:37.109+0900 [DEBUG] plugin.terraform.exe:
```

わからん。

いったん destroy して、auto_init してみるか……

> Error: [ERROR] Refusing to overwrite existing file. Configure `overwrite_on_create` to `true` to override.

cong!

- auto_init しないとブランチさえ空ってことかー……
- 一度つくった repo は、いったん destroy しないと auto_init は通らん
    - AWS CFn でいう UserData みたいなもの
