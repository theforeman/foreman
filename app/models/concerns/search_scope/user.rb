module SearchScope
  module User
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :login, :complete_value => :true
      scoped_search :on => :firstname, :complete_value => :true
      scoped_search :on => :lastname, :complete_value => :true
      scoped_search :on => :mail, :complete_value => :true
      scoped_search :on => :admin, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_admin
      scoped_search :on => :last_login_on, :complete_value => :true, :only_explicit => true
      scoped_search :in => :roles, :on => :name, :rename => :role, :complete_value => true
      scoped_search :in => :roles, :on => :id, :rename => :role_id
      scoped_search :in => :cached_usergroups, :on => :name, :rename => :usergroup, :complete_value => true
    end

    module ClassMethods
      def search_by_admin(key, operator, value)
        value      = value == 'true'
        value      = !value if operator == '<>'
        conditions = [self.table_name, Usergroup.table_name].map do |base|
          "(#{base}.admin = ?" + (value ? ')' : " OR #{base}.admin IS NULL)")
        end
        conditions = conditions.join(value ? ' OR ' : ' AND ')

        {
          :include    => :cached_usergroups,
          :conditions => sanitize_sql_for_conditions([conditions, value, value])
        }
      end
    end
  end
end

