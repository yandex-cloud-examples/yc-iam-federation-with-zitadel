# ========================
# zitadel-gitlab TF-Module
# ========================

variable "gitlab" {
  description = "Gitlab attributes"
  type = object(
    {
      domain     = string # .gitlab.yandexcloud.net
      group_name = string
      token_file = string
    }
  )
}
