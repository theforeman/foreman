class Organization < Taxonomy
  extend FriendlyId
  friendly_id :title
  include Foreman::ThreadSession::OrganizationModel
  include Parameterizable::ByIdName

  has_and_belongs_to_many :locations, :join_table => 'locations_organizations'
  has_many_hosts :dependent => :nullify

  has_many :organization_parameters, :class_name => 'OrganizationParameter', :foreign_key => :reference_id,            :dependent => :destroy, :inverse_of => :organization
  has_many :default_users,           :class_name => 'User',                  :foreign_key => :default_organization_id, :dependent => :nullify
  accepts_nested_attributes_for :organization_parameters, :allow_destroy => true
  include ParameterValidators
  include AccessibleAttributes

  scope :completer_scope, ->(opts) { my_organizations }

  scope :my_organizations, lambda {
    conditions = User.current.admin? ? {} : sanitize_sql_for_conditions([" (taxonomies.id in (?))", User.current.organization_and_child_ids])
    where(conditions)
  }

  def dup
    new = super
    new.locations = locations
    new
  end

  def lookup_value_match
    "organization=#{title}"
  end

  def sti_name
    _("organization")
  end
end
