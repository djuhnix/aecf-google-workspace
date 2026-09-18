# Google Workspace Groups Provisioning
resource "googleworkspace_group" "group" {
  for_each = { for k, v in local.groups : k => v if var.enable_group_creation }

  email       = each.value.email
  name        = each.value.name
  description = each.value.description
  aliases     = each.value.aliases
}

# Group Settings (Permissions, Posting policies, Visibility)
resource "googleworkspace_group_settings" "group_settings" {
  for_each = {
    for email, g in local.groups : email => g
    if var.enable_group_creation && length(keys(g.settings)) >= 0
  }

  email = googleworkspace_group.group[each.key].email

  who_can_join               = try(each.value.settings.who_can_join, "INVITED_CAN_JOIN")
  who_can_view_membership    = try(each.value.settings.who_can_view_membership, "ALL_MANAGERS_CAN_VIEW")
  who_can_post_message       = try(each.value.settings.who_can_post_message, "ANYONE_CAN_POST")
  who_can_view_group         = try(each.value.settings.who_can_view_group, "ALL_MEMBERS_CAN_VIEW")
  who_can_contact_owner      = try(each.value.settings.who_can_contact_owner, "ANYONE_CAN_CONTACT")
  who_can_assist_content     = try(each.value.settings.who_can_assist_content, "OWNERS_AND_MANAGERS")
  allow_external_members     = try(each.value.settings.allow_external_members, "false")
  allow_web_posting          = try(each.value.settings.allow_web_posting, "true")
  primary_language           = try(each.value.settings.primary_language, "fr")
  is_archived                = try(each.value.settings.is_archived, "true")
  archive_only               = try(each.value.settings.archive_only, "false")
  enable_collaborative_inbox = try(each.value.settings.enable_collaborative_inbox, "true")
  message_moderation_level   = try(each.value.settings.message_moderation_level, "MODERATE_NONE")
  spam_moderation_level      = try(each.value.settings.spam_moderation_level, "MODERATE")
}

# Group Memberships Provisioning
resource "googleworkspace_group_member" "member" {
  for_each = { for k, v in local.group_members : k => v if var.enable_group_creation }

  group_id = try(googleworkspace_group.group[each.value.group_email].email, each.value.group_email) # TODO: change to id if needed
  email    = each.value.member_email
  role     = each.value.role
  type     = each.value.type

  depends_on = [
    googleworkspace_group.group,
    googleworkspace_user.user
  ]
}