output "url" {
	value = aws_elastic_beanstalk_environment.default.endpoint_url
}

output "private_key" {
 	value = tls_private_key.default.private_key_pem
}
