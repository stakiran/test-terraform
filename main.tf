provider "github" {

}

resource "github_repository" "test-from-terraform" {
  name        = "test-from-terraform"
  description = "Terraform からつくってみたものです(ここを書き換えて再apply)"

  visibility = "public"

  has_wiki     = true
  has_issues   = true
  has_projects = true
}

