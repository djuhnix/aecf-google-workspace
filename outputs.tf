output "org_units_created" {
  description = "List of created Organizational Units"
  value = merge(
    { for k, v in googleworkspace_org_unit.root : k => { id = v.id, path = v.org_unit_path } },
    { for k, v in googleworkspace_org_unit.sub : k => { id = v.id, path = v.org_unit_path } }
  )
}

output "groups_created" {
  description = "List of created Groups and their email addresses"
  value = {
    for k, v in googleworkspace_group.group : k => {
      id    = v.id
      email = v.email
    }
  }
}

output "users_created" {
  description = "Summary of created user accounts"
  value = {
    for k, v in googleworkspace_user.user : k => {
      id            = v.id
      primary_email = v.primary_email
      org_unit_path = v.org_unit_path
    }
  }
}

output "group_memberships_count" {
  description = "Total number of group memberships configured"
  value       = length(googleworkspace_group_member.member)
}
