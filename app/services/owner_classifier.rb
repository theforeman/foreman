class OwnerClassifier
  def initialize(id_and_type)
    @id_and_type = id_and_type
  end

  def self.classify_owner(id_and_type)
    return nil if id_and_type.blank?

    validate_input_format!(id_and_type)

    owner_type = id_and_type.end_with?('Users') ? User : Usergroup
    owner_type.find(id_and_type.to_i)
  end

  def user_or_usergroup
    Foreman::Deprecation.deprecation_warning("3.12", "`user_or_usergroup` is deprecated, use `classify_owner` instead.")

    OwnerClassifier.classify_owner(@id_and_type)
  end

  def self.validate_input_format!(id_and_type)
    unless id_and_type.is_a?(String) && id_and_type.match?(/^\d+-(Users|Usergroups)$/)
      raise ArgumentError, _("Invalid input format. Please use the format '${id}-[Users|Usergroups]'.")
    end
  end
end
