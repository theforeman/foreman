class ActiveRecord::Base
  extend Host::Hostmix
  include HasManyCommon
  include StripWhitespace
  include Parameterizable::ById
end

# Permit safemode template rendering to have basic read-only access over
# model relations
class ActiveRecord::AssociationRelation::Jail < Safemode::Jail
  allow :[], :each, :first, :to_a
end

class ActiveRecord::Associations::CollectionProxy::Jail < Safemode::Jail
  allow :[], :each, :first, :to_a
end
