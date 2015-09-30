class Location < Taxonomy
  extend FriendlyId
  friendly_id :title
  include Foreman::ThreadSession::LocationModel
  include Parameterizable::ByIdName

  has_and_belongs_to_many :organizations, :join_table => 'locations_organizations'
  has_many_hosts :dependent => :nullify

  has_many :location_parameters, :class_name => 'LocationParameter', :foreign_key => :reference_id, :dependent => :destroy, :inverse_of => :location
  has_many :default_users,       :class_name => 'User',              :foreign_key => :default_location_id
  accepts_nested_attributes_for :location_parameters, :allow_destroy => true
  include ParameterValidators
  include AccessibleAttributes

  scope :completer_scope, ->(opts) { my_locations }

  scope :my_locations, lambda {
    conditions = User.current.admin? ? {} : sanitize_sql_for_conditions([" (taxonomies.id in (?))", User.current.location_and_child_ids])
    where(conditions)
  }

  def dup
    new = super
    new.organizations = organizations
    new
  end

  def lookup_value_match
    "location=#{title}"
  end

  def sti_name
    _("location")
  end
end
