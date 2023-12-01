module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules/modules/bigeye?ref=v0.2.0"
  environment = "test"
  instance    = "bigeye"

  # Your parent DNS name here, e.g. bigeye.my-company.com
  top_level_dns_name = ""

  # get these from bigeye
  image_registry = ""
  image_tag      = ""
}

