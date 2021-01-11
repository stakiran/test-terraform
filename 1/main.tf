provider "github" {

}

resource "github_repository" "repo" {
  name        = "test-from-terraform"
  description = "Terraform からつくってみたものです"
  visibility  = "public"
  // これで初期化しないと github_repository_file で branch not found になる
  auto_init = true
}

output "reponame" {
  value = github_repository.repo.name
}

resource "github_repository_file" "readme" {
  repository          = github_repository.repo.name
  file                = "README.md"
  content             = "# これは Terraform から作成したものです"
  overwrite_on_create = true
}
