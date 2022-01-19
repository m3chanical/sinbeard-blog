variable "domain_name" {
    type = string
    description = "domain name for the website"
}

variable "bucket_name" {
    type = string
    description = "name of the bucket without the www prefix"
}

variable "common_tags" {
    description = "common tags applied to all components"
}