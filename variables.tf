variable "AWS_REGION" {
	type = string
}
variable "AWS_ACCESS_KEY" {
	type = string
}
variable "AWS_SECRET_KEY" {
	type = string
}
variable "RACK_ENV" {
	type = string
}
variable "DOMAIN_NAME" {
	type = string
}
variable "APP_TAGS" {
	type = string
}
variable "APP_NAME" {
	type = string
}
variable "VPC_ID" {
	type = string
}
variable "EC2_SUBNETS" {
	type = string
}
variable "ELB_SUBNETS" {
	type = string
}
variable "INSTANCE_TYPE" {
	type = string
}
variable "DISK_SIZE" {
	type = string
}
variable "KEYPAIR" {
	type = string
}
variable "SSH_ALLOWED" {
	type = string
}
variable "ALARM_SNS_TOPIC" {
	type = string
}
variable "APP_VERSION"{
	type = string
}
variable "DATABASE_ENGINE" {
	type = string
}
variable "DATABASE_ENGINE_VERSION" {
	type = string
}
variable "DATABASE_PASSWORD" {
	type = string
}
variable "DATABASE_PORT" {
	type = string
}
variable "DATABASE_USERNAME" {
	type = string
}
variable "PROJECT_NAME"{
	type = string
}
