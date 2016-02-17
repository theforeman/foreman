class ActiveRecord::Base
  extend Host::Hostmix
  include HasManyCommon
  include StripWhitespace
  include Parameterizable::ById

  def only_changed?(field_names)
    self.changes.size == field_names.size && field_names.count{ |field_name| self.changes[field_name].present? } == field_names.size
  end
end

# Permit safemode template rendering to have basic read-only access over
# model relations
class ActiveRecord::AssociationRelation::Jail < Safemode::Jail
  allow :[], :each, :first, :to_a
end

class ActiveRecord::Associations::CollectionProxy::Jail < Safemode::Jail
  allow :[], :each, :first, :to_a
end
