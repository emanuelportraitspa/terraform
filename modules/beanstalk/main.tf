data "aws_elastic_beanstalk_hosted_zone" "current" {}

resource "aws_s3_bucket" "default" {
	bucket = "${var.PROJECT_NAME}-app"

	force_destroy = true
}

resource "aws_elastic_beanstalk_application_version" "default" {
	application = aws_elastic_beanstalk_application.default.name
	bucket = aws_s3_bucket.default.id
	key = "${var.APP_VERSION}.zip"
	name = var.APP_VERSION
}

resource "aws_elastic_beanstalk_application" "default" {
	description = "${var.PROJECT_NAME} application"
	name = var.PROJECT_NAME
}
resource "aws_elastic_beanstalk_environment" "default" {
	application = aws_elastic_beanstalk_application.default.name
	description = "${var.PROJECT_NAME} Api"
	version_label = aws_elastic_beanstalk_application_version.default.id

	name = var.RACK_ENV
	solution_stack_name = "64bit Amazon Linux 2018.03 v2.11.4 running Ruby 2.6 (Puma)"
	tier= "Api"

	// Instance
	setting {
		name = "EC2KeyName"
		namespace = "aws:autoscaling:launchconfiguration"
		value = aws_key_pair.default.key_name
	}
	setting {
		name = "InstanceTypes"
		namespace = "aws:ec2:instances"
		value = "t3.micro"
	}
	setting {
		name = "MaxSize"
		namespace = "aws:autoscaling:asg"
		value = "1"
	}
	setting {
		name = "MinSize"
		namespace = "aws:autoscaling:asg"
		value = "1"
	}
	setting {
		name = "RollingUpdateEnabled"
		namespace = "aws:autoscaling:updatepolicy:rollingupdate"
		value = "false"
	}
	setting {
		name = "SecurityGroups"
		namespace = "aws:autoscaling:launchconfiguration"
		value = module.database.aws_security_group.name
	}

	// Environmental varaibles
	setting {
		name = "RACK_ENV"
		namespace = "aws:elasticbeanstalk:application:environment"
		value = var.RACK_ENV
	}
	setting {
		name = "BUNDLE_WITHOUT"
		namespace = "aws:elasticbeanstalk:application:environment"
		value = "test:development"
	}
	setting {
		name = "RAILS_SKIP_ASSET_COMPILATION"
		namespace = "aws:elasticbeanstalk:application:environment"
		value = "false"
	}
	setting {
		name = "RAILS_SKIP_MIGRATIONS"
		namespace = "aws:elasticbeanstalk:application:environment"
		value = "false"
	}
	setting {
		name = "DATABASE_HOST"
		namespace = "aws:elasticbeanstalk:application:environment"
		value = module.database.host
	}
	setting {
		name = "DATABASE_PASSWORD"
		namespace = "aws:elasticbeanstalk:application:environment"
		value = module.database.password
	}
	setting {
		name = "DATABASE_PORT"
		namespace = "aws:elasticbeanstalk:application:environment"
		value = module.database.port
	}
	setting {
		name = "DATABASE_USERNAME"
		namespace = "aws:elasticbeanstalk:application:environment"
		value = module.database.username
	}
	setting {
		name = "SECRET_KEY_BASE"
		namespace = "aws:elasticbeanstalk:application:environment"
		value = "MY_SUPER_SECURE_SECRET_KEY"
	}
}

resource "aws_key_pair" "default" {
	key_name = "${var.PROJECT_NAME}-SSH-key"
	public_key = tls_private_key.default.public_key_openssh
}

resource "tls_private_key" "default" {
	algorithm = "RSA"
	rsa_bits  = 4096
}

resource "aws_lb_listener" "https_redirect" {
  load_balancer_arn = aws_elastic_beanstalk_environment.default.load_balancers[0]
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_lb" "eb_lb" {
  arn = aws_elastic_beanstalk_environment.default.load_balancers[0]
}

resource "aws_security_group_rule" "allow_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = tolist(data.aws_lb.eb_lb.security_groups)[0]
}


