// == Uncomment block below if Manager role is required ==

/* 
// Manager account in Zitadel Organization
resource "zitadel_human_user" "manager" {
  count                        = var.zitadel_org.manager_create ? 1 : 0
  org_id                       = zitadel_org.org.id
  user_name                    = "${var.zitadel_org.org_name}-manager"
  first_name                   = title(var.zitadel_org.org_name)
  last_name                    = "Manager"
  display_name                 = "${upper(var.zitadel_org.org_name)} Org Manager"
  preferred_language           = "en"
  email                        = "manager@${var.zitadel_org.org_name}.myorg"
  is_email_verified            = true
  initial_password             = substr(base64sha256(format("%s%s", timestamp(), var.zitadel_org.org_name)), 5, 20)
  initial_skip_password_change = true

  lifecycle {
    ignore_changes = [initial_password, email]
  }
}

// Manager's role in Zitadel Organization
// https://zitadel.com/docs/guides/manage/console/managers#roles
resource "zitadel_org_member" "manager_org_role" {
  count   = var.zitadel_org.manager_create ? 1 : 0
  org_id  = zitadel_org.org.id
  user_id = zitadel_human_user.manager.id
  roles   = ["ORG_USER_MANAGER"]
}

output "zitadel_org_manager_name" {
  value = zitadel_human_user.manager.user_name
}

output "zitadel_org_manager_password" {
  value = zitadel_human_user.manager.initial_password
}
*/
