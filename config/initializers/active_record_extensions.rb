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

# Provide FK helper present in Foreigner (used on Rails 4.1 and older) and
# in the future in Rails 5, but that are missing in 4.2.
#
# From https://github.com/rails/rails/commit/6298ac70
class ActiveRecord::Migration
  def foreign_key_exists?(from_table, options_or_to_table = {})
    return unless supports_foreign_keys?

    if options_or_to_table.is_a?(Hash)
      options = options_or_to_table
    else
      options = { column: foreign_key_column_for(options_or_to_table) }
    end

    foreign_keys(from_table).any? {|fk| options.keys.all? {|key| fk.options[key].to_s == options[key].to_s } }
  end
end
