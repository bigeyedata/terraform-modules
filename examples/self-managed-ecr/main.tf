module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v20.8.1"
  environment = "test"
  instance    = "bigeye"

  # Your parent DNS name here, e.g. bigeye.my-company.com
  top_level_dns_name = ""

  image_registry = format("%s.dkr.ecr.us-west-2.amazonaws.com", aws_ecr_repository.bigeye_ecr[0].registry_id)

  # Bigeye app version.  You can list the tags available in the image_registry (using the latest is always recommended).
  image_tag = "1.34.0"
}

# Create local ECR repos for caching of images.  See run list_bigeye_images.sh and get_bigeye_image.sh for
# caching Bigeye's images in these local ECR repos.
locals {
  bigeye_repos = [
    "datawatch",
    "haproxy",
    "monocle",
    "scheduler",
    "temporal",
    "temporalui",
    "toretto",
    "web",
  ]
}

resource "aws_ecr_repository" "bigeye_ecr" {
  count = length(local.bigeye_repos)
  name  = local.bigeye_repos[count.index]
  encryption_configuration {
    encryption_type = "AES256"
  }

  # Bigeye's ECR uses immutable tags, so there should be no issue here with conflicts.
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = false
  }
}

# List repo urls for locally created_repos
output "local_ecr_repos" {
  value = [
    for i in range(length(aws_ecr_repository.bigeye_ecr)) :
    aws_ecr_repository.bigeye_ecr[i].repository_url
  ]
}
