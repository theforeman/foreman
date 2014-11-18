module SearchScope
  module FactValue
    extend ActiveSupport::Concern

    included do
      include ScopedSearchExtensions

      scoped_search :on => :value, :in_key=> :fact_name, :on_key=> :name, :rename => :facts, :complete_value => true, :only_explicit => true
      scoped_search :on => :value, :default_order => true
      scoped_search :in => :fact_name, :on => :name, :complete_value => true, :alias => "fact"
      scoped_search :in => :host,      :on => :name, :complete_value => true, :rename => :host, :ext_method => :search_by_host, :only_explicit => true
      scoped_search :in => :hostgroup, :on => :name, :complete_value => true, :rename => :"host.hostgroup", :only_explicit => true
      scoped_search :in => :fact_name, :on => :short_name, :complete_value => true, :alias => "fact_short_name"
    end

    module ClassMethods
      def search_by_host(key, operator, value)
        search_term = value =~ /\A\d+\Z/ ? 'id' : 'name'
        conditions = sanitize_sql_for_conditions(["hosts.#{search_term} #{operator} ?", value_to_sql(operator, value)])
        search     = ::FactValue.joins(:host).where(conditions).select('fact_values.id').map(&:id).uniq

        return { :conditions => "1=0" } if search.empty?
        { :conditions => "fact_values.id IN(#{search.join(',')})" }
      end
    end
  end
end
