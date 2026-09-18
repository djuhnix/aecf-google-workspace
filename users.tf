# Random password generator for users without explicit initial passwords
resource "random_password" "initial_user_password" {
  for_each = {
    for email, user in local.users :
    email => user
    if user.initial_password == null && user.init_password == true
  }

  length           = 16
  special          = true
  override_special = "!@#$%&*"
}

# User Account Provisioning
resource "googleworkspace_user" "user" {
  for_each = var.enable_user_creation ? local.users : {}

  primary_email = each.key
  password      = coalesce(each.value.initial_password, try(random_password.initial_user_password[each.key].result, var.default_user_password))

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  org_unit_path                 = each.value.org_unit_path
  suspended                     = each.value.suspended
  change_password_at_next_login = each.value.change_password_at_next_login
  recovery_email                = each.value.recovery_email
  recovery_phone                = each.value.recovery_phone

  aliases = each.value.aliases

  # Ensure Organizational Units exist before assigning users to them
  depends_on = [
    googleworkspace_org_unit.root,
    googleworkspace_org_unit.sub
  ]

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}
