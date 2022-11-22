module "database" {

	source = "./modules/database"

	DATABASE_ENGINE = var.DATABASE_ENGINE
	DATABASE_ENGINE_VERSION = var.DATABASE_ENGINE_VERSION
	DATABASE_PASSWORD = var.DATABASE_PASSWORD
	DATABASE_PORT = var.DATABASE_PORT
	DATABASE_USERNAME = var.DATABASE_USERNAME
	PROJECT_NAME = var.PROJECT_NAME
}

module "beanstalk" {

  source = "./modules/beanstalk/"

  app_tags         = var.APP_TAGS
  application_name = var.APP_NAME
  vpc_id           = var.VPC_ID
  ec2_subnets      = var.EC2_SUBNETS
  elb_subnets      = var.ELB_SUBNETS
  instance_type    = var.INSTANCE_TYPE
  disk_size        = var.DISK_SIZE
  keypair          = var.KEYPAIR
  sshrestrict      = var.SSH_ALLOWED
}

