class Organization < Taxonomy
  include Foreman::ThreadSession::OrganizationModel
  include Parameterizable::ByIdName

  has_and_belongs_to_many :locations, :join_table => "locations_organizations"
  has_many_hosts :dependent => :nullify

  has_many :organization_parameters, :class_name => 'OrganizationParameter', :foreign_key => :reference_id,            :dependent => :destroy, :inverse_of => :organization
  has_many :default_users,           :class_name => 'User',                  :foreign_key => :default_organization_id, :dependent => :nullify
  accepts_nested_attributes_for :organization_parameters, :allow_destroy => true
  include ParameterValidators

  scope :completer_scope, lambda { |opts| my_organizations }

  scope :my_organizations, lambda {
    conditions = User.current.admin? ? {} : sanitize_sql_for_conditions([" (taxonomies.id in (?))", User.current.organization_and_child_ids])
    where(conditions)
  }

  # returns self and parent parameters as a hash
  def parameters(include_source = false)
    hash = {}
    ids = ancestor_ids
    ids << id unless new_record? or self.frozen?
    # need to pull out the organizations to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    orgs = ids.size == 1 ? [self] : Organization.sort_by_ancestry(Organization.includes(:organization_parameters).find(ids))
    orgs.each do |org|
      org.organization_parameters.each {|p| hash[p.name] = include_source ? {:value => p.value, :source => N_('organization').to_sym, :source_name => org.title} : p.value }
    end
    hash
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
