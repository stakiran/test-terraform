# test-terraform
Terraform の練習

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

