# Root Organizational Units
resource "googleworkspace_org_unit" "root" {
  for_each = local.root_org_units

  name                 = each.value.name
  parent_org_unit_path = each.value.parent_org_unit_path
  description          = each.value.description
  block_inheritance    = each.value.block_inheritance
}

# Sub-Organizational Units
resource "googleworkspace_org_unit" "sub" {
  for_each = local.sub_org_units

  name                 = each.value.name
  parent_org_unit_path = each.value.parent_org_unit_path
  description          = each.value.description
  block_inheritance    = each.value.block_inheritance

  depends_on = [googleworkspace_org_unit.root]
}
