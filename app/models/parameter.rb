class Parameter < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include HiddenValue

  validates_lengths_from_database

  include Authorizable
  validates :name, :presence => true, :no_whitespace => true

  def self.inherited(child)
    child.instance_eval do
      scoped_search :on => :name, :complete_value => true
      scoped_search :on => :value, :complete_value => :true
    end
    super
  end

  default_scope -> { order("parameters.name") }

  before_create :set_priority

  PRIORITY = { :common_parameter => 0,
               :organization_parameter => 10,
               :location_parameter => 20,
               :domain_parameter => 30,
               :subnet_parameter => 40,
               :os_parameter => 50,
               :group_parameter => 60,
               :host_parameter => 70
             }

  def self.type_priority(type)
    PRIORITY.fetch(type.to_s.underscore.to_sym, nil) unless type.nil?
  end

  private

  def set_priority
    self.priority = Parameter.type_priority(type)
  end

  def skip_strip_attrs
    ['value']
  end
end
