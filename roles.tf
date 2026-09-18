# Admin Role Assignments
# resource "googleworkspace_role_assignment" "assignment" {
#   for_each = local.role_assignments

#   assigned_to = each.value.assigned_to
#   role_id     = each.value.role_id
#   scope_type  = each.value.scope_type
#   org_unit_id = each.value.org_unit_id

#   depends_on = [
#     googleworkspace_user.user,
#     googleworkspace_group.group
#   ]
# }
