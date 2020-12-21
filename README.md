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
