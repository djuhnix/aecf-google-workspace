locals {
  # Load raw YAML files with fallback if empty
  raw_org_units = try(yamldecode(file("${var.config_dir}/org_units.yaml")), { org_units = [] })
  raw_groups    = try(yamldecode(file("${var.config_dir}/groups.yaml")), { groups = [] })
  raw_users     = try(yamldecode(file("${var.config_dir}/users.yaml")), { users = [] })
  raw_roles     = try(yamldecode(file("${var.config_dir}/roles.yaml")), { role_assignments = [] })

  # --- Organizational Units ---
  # Map keyed by full path (e.g., "/Engineering" or "/Engineering/DevOps")
  org_units_list = try(local.raw_org_units.org_units, [])

  root_org_units = {
    for ou in local.org_units_list :
    ou.path => {
      name                 = ou.name
      parent_org_unit_path = "/"
      description          = try(ou.description, "")
      block_inheritance    = try(ou.block_inheritance, false)
      email_prefix         = try(ou.email_prefix, null)
      shared_drive         = try(ou.shared_drive, true)
    }
    if try(ou.parent_path, "/") == "/"
  }

  sub_org_units = {
    for ou in local.org_units_list :
    ou.path => {
      name                 = ou.name
      parent_org_unit_path = try(ou.parent_path, "/")
      description          = try(ou.description, "")
      block_inheritance    = try(ou.block_inheritance, false)
      email_prefix         = try(ou.email_prefix, null)
      shared_drive         = try(ou.shared_drive, true)
    }
    if try(ou.parent_path, "/") != "/"
  }

  org_units = merge(local.root_org_units, local.sub_org_units)

  # --- Groups ---
  groups_list = try(local.raw_groups.groups, [])

  # Dynamic groups created for each OU under /01_poles and /02_entites
  dynamic_ou_groups = {
    for path, ou in local.org_units :
    "ou_group:${path}" => {
      email       = "${coalesce(ou.email_prefix, reverse(split("/", path))[0])}@${var.domain}"
      name        = "OU Group - ${ou.name}"
      description = "Automatic group for members of ${ou.name}"
      aliases     = []
      settings    = {}
    }
    if startswith(path, "/01_poles") || startswith(path, "/02_entites")
  }

  groups = merge({
    for g in local.groups_list :
    g.email => {
      email       = g.email
      name        = g.name
      description = try(g.description, "")
      aliases     = try(g.aliases, [])
      settings    = try(g.settings, {})
      members     = try(g.members, [])
    }
  }, local.dynamic_ou_groups)

  # Flatten group members for group_memberships resource
  group_members_flat = flatten([
    # 1. Explicit members from YAML
    [
      for g in local.groups_list : [
        for m in try(g.members, []) : {
          group_email  = g.email
          member_email = m.email
          role         = upper(try(m.role, "MEMBER"))
          type         = upper(try(m.type, "USER"))
        }
      ]
    ],
    # 2. Dynamic members based on OU path
    [
      for path, ou in local.org_units : [
        for email, user in local.users : {
          group_email  = local.dynamic_ou_groups["ou_group:${path}"].email
          member_email = email
          role         = "MEMBER"
          type         = "USER"
        }
        if user.org_unit_path == path && (startswith(path, "/01_poles") || startswith(path, "/02_entites"))
      ]
    ],
    # 3. Explicit members from users.yaml
    [
      for email, user in local.users : [
        for g in user.groups : {
          group_email  = g.email
          member_email = email
          role         = upper(try(g.role, "MEMBER"))
          type         = "USER"
        }
        if contains([for gr in local.groups : gr.email], g.email)
      ]
    ]
  ])

  group_members = {
    for item in local.group_members_flat :
    "${item.group_email}:${item.member_email}" => item
  }

  # --- Users ---
  users_list = try(local.raw_users.users, [])
  users = {
    for u in local.users_list :
    u.email => {
      given_name                    = u.first_name
      family_name                   = u.last_name
      org_unit_path                 = try(u.org_unit_path, "/")
      suspended                     = try(u.suspended, false)
      change_password_at_next_login = try(u.change_password_at_next_login, true)
      recovery_email                = try(u.recovery_email, null)
      recovery_phone                = try(u.recovery_phone, null)
      aliases                       = try(u.aliases, [])
      initial_password              = try(u.initial_password, null)
      init_password                 = try(u.init_password, true)
      groups                        = try(u.groups, [])
    }
  }

  # --- Role Assignments ---
  # Filter for sub-OUs of /01_poles (excluding the root /01_poles itself)
  poles_sub_units = {
    for path, ou in local.org_units :
    path => ou
    if startswith(path, "/01_poles") && path != "/01_poles"
  }

}