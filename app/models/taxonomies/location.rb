class Location < Taxonomy
  extend FriendlyId
  friendly_id :title
  include Foreman::ThreadSession::LocationModel
  include Parameterizable::ByIdName
  include LookupValueConnector

  has_and_belongs_to_many :organizations, :join_table => 'locations_organizations'
  has_many_hosts :dependent => :nullify
  before_destroy EnsureNotUsedBy.new(:hosts)

  has_many :default_users,       :class_name => 'User',              :foreign_key => :default_location_id

  scope :completer_scope, ->(opts) { my_locations }

  scope :my_locations, lambda { |user = User.current|
    conditions = user.admin? ? {} : sanitize_sql_for_conditions([" (taxonomies.id in (?))", user.location_and_child_ids])
    where(conditions)
  }

  def dup
    new = super
    new.organizations = organizations
    new
  end

  def sti_name
    _("location")
  end
end
