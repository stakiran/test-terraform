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

### 2 