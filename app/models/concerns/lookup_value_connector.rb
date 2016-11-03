module LookupValueConnector
  extend ActiveSupport::Concern

  included do
   # include Foreman::Controller::Parameters::LookupValueConnector
    has_many :lookup_values, :primary_key => :lookup_value_matcher, :foreign_key => :match, :dependent => :destroy
    accepts_nested_attributes_for :lookup_values, :allow_destroy => true
    validates_associated :lookup_values

    before_save :set_lookup_value_matcher
    include ParameterValidators
    scoped_search :in => :lookup_values, :on => :value, :complete_value => true, :only_explicit => true, :rename => :params, :ext_method => :search_by_params

    # Replacement of accepts_nested_attributes_for :lookup_values,
    # to work around the lack of `host_id` column in lookup_values.
    def lookup_values_attributes=(lookup_values_attributes)
      lookup_values_attributes.each_value do |attribute|
        attr = attribute.dup
        id = attr.delete(:id)
        destroy = ActiveRecord::Type::Boolean.new.type_cast_from_user(attr.delete(:_destroy))
        if id.present?
          lookup_value = self.lookup_values.to_a.find { |i| i.id.to_i == id.to_i }
          if lookup_value
            mark_for_destruction = destroy
            lookup_value.attributes = attr
            lookup_value.mark_for_destruction if mark_for_destruction
          end
        elsif !destroy
          attr.merge!(:match => lookup_value_match) unless attr[:match].present?
          self.lookup_values.build(attr.merge(:host_or_hostgroup => self).to_hash)
        end
      end
    end
  end

  module ClassMethods
    def search_by_params(key, operator, value)
      key_name = key.sub(/^.*\./,'')
      key_id = GlobalLookupKey.where(:key => key_name)
      value_condition = sanitize_sql_for_conditions(["lookup_values.lookup_key_id = ? and lookup_values.value #{operator} ?", key_id, value_to_sql(operator, value.to_yaml)])
      condition = self.select("#{self.table_name}.id").joins(:lookup_values).where(value_condition).to_sql
      {:conditions => 'id IN (%s)' % condition }
    end
  end

  def lookup_value_match
    "#{self.class.model_name.to_s.downcase}=#{self.title}"
  end

  protected

  def set_lookup_value_matcher
    #in migrations, this method can get called before the attribute exists
    #the #attribute_names method is cached, so it's not going to be a performance issue
    return true unless self.class.attribute_names.include?("lookup_value_matcher")
    self.lookup_value_matcher = lookup_value_match
  end
end
