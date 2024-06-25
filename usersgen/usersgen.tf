# =======================
# Users TF code generator
# =======================

locals {
  users_src = var.zitadel_users
  users_out = "../../zitadel-config/users.tf"

  users_data = yamldecode(file(local.users_src))
  users_list = tolist(keys(local.users_data))

  users_tf_data = flatten([
    for user in local.users_list : {
      user_tf_code = templatefile("${path.module}/user.tpl", {
        USER_UNAME = user
        USER_FNAME = local.users_data[user].fname
        USER_LNAME = local.users_data[user].lname
        USER_LANG  = local.users_data[user].lang
        USER_EMAIL = local.users_data[user].email
        USER_PASS  = local.users_data[user].pass
      })
    }
  ])
}

# Check user's password at TF state:
# terraform state show module.zitadel-config.terracurl_request.admin | grep newPassword | awk -F'"' '{print $6}'

resource "local_file" "users_tf_file" {
  content         = join("", local.users_tf_data[*].user_tf_code)
  filename        = local.users_out
  file_permission = 644
}
