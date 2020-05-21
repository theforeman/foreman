class Organization < Taxonomy
  apipie :class, desc: "A class representing an Organization object" do
    sections only: %w[all additional]
    prop_group :basic_model_props, ApplicationRecord, meta: { example: 'Red Hat' }
    prop_group :taxonomy_props, Taxonomy, meta: { model_name: 'Organization', example: 'Red Hat/Engineering' }
  end

  extend FriendlyId
  friendly_id :title
  include Foreman::ThreadSession::OrganizationModel
  include Parameterizable::ByIdName

  has_and_belongs_to_many :locations, :join_table => 'locations_organizations', :validate => false
  has_many_hosts :dependent => :nullify
  before_destroy EnsureNotUsedBy.new(:hosts)
  has_many :reports, :through => :hosts, :class_name => 'ConfigReport'

  has_many :organization_parameters, :class_name => 'OrganizationParameter', :foreign_key => :reference_id,            :dependent => :destroy, :inverse_of => :organization
  has_many :default_users,           :class_name => 'User',                  :foreign_key => :default_organization_id, :dependent => :nullify
  accepts_nested_attributes_for :organization_parameters, :allow_destroy => true
  include ParameterValidators

  scope :completer_scope, ->(opts) { my_organizations }

  scoped_search :on => :id, :validator => ScopedSearch::Validators::INTEGER, :rename => 'organization_id', :only_explicit => true

  scope :my_organizations, lambda { |user = User.current|
    user.admin? ? all : where(id: user.organization_and_child_ids)
  }

  class Jail < ::Safemode::Jail
    allow :id, :name, :title, :created_at, :updated_at, :description
  end

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
