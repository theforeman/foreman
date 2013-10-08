module RolesHelper

  def letters
    perms_by_letter.keys
  end

  def perms_by_letter
    @perms_by_letter ||= ActiveSupport::OrderedHash[role_permissions.group_by { |p| p.security_block.to_s[0].chr.upcase }.sort]
  end

  def perms_by_block permissions
    ActiveSupport::OrderedHash[permissions.group_by { |p| p.security_block.to_s }.sort]
  end

  private

  def role_permissions
    @role_permissions ||= @role.setable_permissions
  end

end