class OwnerClassifier
  def initialize(id_and_type)
    @id_and_type = id_and_type
  end

  def user_or_usergroup
    return nil unless @id_and_type =~ /^\d+-(Users|Usergroups)$/
    @id_and_type.include?('Users') ? User.find_by_id(@id_and_type.to_i) : Usergroup.find_by_id(@id_and_type.to_i)
  end
end
