module SearchScope
  module Filter
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :search, :complete_value => true
      scoped_search :on => :limited, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_limited, :only_explicit => true
      scoped_search :on => :unlimited, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_unlimited, :only_explicit => true
      scoped_search :in => :role, :on => :id, :rename => :role_id
      scoped_search :in => :role, :on => :name, :rename => :role
      scoped_search :in => :permissions, :on => :resource_type, :rename => :resource
      scoped_search :in => :permissions, :on => :name,          :rename => :permission
    end

    module ClassMethods
      def search_by_unlimited(key, operator, value)
        search_by_limited(key, operator, value == 'true' ? 'false' : 'true')
      end

      def search_by_limited(key, operator, value)
        value      = value == 'true'
        value      = !value if operator == '<>'
        conditions = value ? limited.where_values.join(' AND ') : unlimited.where_values.map(&:to_sql).join(' AND ')
        { :conditions => conditions }
      end
    end
  end
end

