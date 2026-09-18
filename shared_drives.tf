# # Google Workspace Shared Drives (Implemented via GAM Hybrid Approach)
# # Since Shared Drives are Drive API resources and not Admin SDK resources, 
# # we use GAM via local-exec to ensure state is managed through our config.

# resource "null_resource" "shared_drive_provisioning" {
#   for_each = { for k, v in local.poles_sub_units : k => v if v.shared_drive != false }

#   # Trigger update if the OU name changes
#   triggers = {
#     ou_name = each.value.name
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#       DRIVE_NAME="${each.value.name} - Shared Drive"
#       MANAGER_EMAIL="${coalesce(each.value.email_prefix, reverse(split("/", each.key))[0])}@${var.domain}"

#       chmod +x ./scripts/manage_shared_drive.sh
#       ./scripts/manage_shared_drive.sh "$DRIVE_NAME" "$MANAGER_EMAIL"
#     EOT
#   }

#   depends_on = [
#     googleworkspace_org_unit.root,
#     googleworkspace_org_unit.sub
#   ]
# }
