# Permit safemode template rendering to have basic read-only access over
# model relations
class ActiveRecord::AssociationRelation::Jail < Safemode::Jail
  allow :[], :each, :first, :to_a, :map, :find_in_batches, :size, :group_by, :ids
end

class ActiveRecord::Relation::Jail < Safemode::Jail
  allow :[], :each, :first, :to_a, :map, :find_in_batches, :size, :group_by, :ids
end

class ActiveRecord::Associations::CollectionProxy::Jail < Safemode::Jail
  allow :[], :each, :first, :to_a, :map, :find_in_batches, :size, :group_by, :ids
end

class ActiveRecord::Batches::BatchEnumerator::Jail < Safemode::Jail
  allow :each, :each_record, :map, :to_a, :first, :[], :size
end

class URI::Generic::Jail < Safemode::Jail
  allow :host, :path, :port, :query, :scheme
end

class ActiveSupport::TimeWithZone::Jail < Safemode::Jail
  allow *Safemode.core_jail_methods(Time).uniq
end
