
variable "users_list" {
  description = "YAML file name with users"
}

variable "template_file" {
  description = "Template file for user resources"
  default     = "users.tpl"
}

variable "template_data" {
  description = "Data for template"
  type        = string
  default     = ""
}
