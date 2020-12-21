provider "github" {

}

resource "github_repository" "repo" {
  name        = "test-from-terraform"
  description = "Terraform からつくってみたものです(ここを書き換えて再apply)"

  visibility = "public"

  has_wiki     = false
  has_issues   = false
  has_projects = false
}

output "reponame" {
  value = github_repository.repo.name
}

resource "github_repository_file" "readme" {
  repository = github_repository.repo.name
  branch     = "main"
  file       = "README.md"
  content    = "# これは Terraform から作成したものです"
}
