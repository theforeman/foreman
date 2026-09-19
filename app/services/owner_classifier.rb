class OwnerClassifier
  def self.classify_owner(id_and_type)
    return nil if id_and_type.blank?

    validate_input_format!(id_and_type)

    owner_type = id_and_type.end_with?('Users') ? User : Usergroup
    owner_type.find(id_and_type.to_i)
  end

  def self.validate_input_format!(id_and_type)
    unless id_and_type.is_a?(String) && id_and_type.match?(/^\d+-(Users|Usergroups)$/)
      raise ArgumentError, _("Invalid input format. Please use the format '${id}-[Users|Usergroups]'.")
    end
  end
end
