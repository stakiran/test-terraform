provider "github" {

}

resource "github_repository" "repo" {
  name        = "test-from-terraform"
  description = "Terraform からつくってみたものです"
  visibility  = "public"
  auto_init   = true
}

resource "github_branch_default" "repo" {
  repository = github_repository.repo.name
  branch     = "master"
}

output "reponame" {
  value = github_repository.repo.name
}

output "branch" {
  value = github_branch_default.repo
}

resource "github_repository_file" "readme" {
  repository = github_repository.repo.name
  branch     = github_branch_default.repo.branch
  file       = "README.md"
  content    = "# これは Terraform から作成したものです"
}
