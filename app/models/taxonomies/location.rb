class Location < Taxonomy
  extend FriendlyId
  friendly_id :title
  include Foreman::ThreadSession::LocationModel
  include Parameterizable::ByIdName

  FORBIDDEN_NAMES = ['any location']

  has_and_belongs_to_many :organizations, :join_table => 'locations_organizations', :validate => false
  has_many_hosts :dependent => :nullify
  before_destroy EnsureNotUsedBy.new(:hosts)
  has_many :reports, :through => :hosts, :class_name => 'ConfigReport'

  has_many :location_parameters, :class_name => 'LocationParameter', :foreign_key => :reference_id, :dependent => :destroy, :inverse_of => :location
  has_many :default_users,       :class_name => 'User',              :foreign_key => :default_location_id
  accepts_nested_attributes_for :location_parameters, :allow_destroy => true
  include ParameterValidators

  scope :completer_scope, ->(opts) { my_locations }

  scoped_search :on => :id, :validator => ScopedSearch::Validators::INTEGER, :rename => 'location_id', :only_explicit => true

  scope :my_locations, lambda { |user = User.current|
    user.admin? ? all : where(id: user.location_and_child_ids)
  }

  validate :is_reserved_name?

  def is_reserved_name?
    return unless FORBIDDEN_NAMES.include?(name&.downcase)

    errors.add(:name, "#{name} is reserved.")
  end

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
