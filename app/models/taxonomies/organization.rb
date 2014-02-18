class Organization < Taxonomy
  include Foreman::ThreadSession::OrganizationModel

  has_and_belongs_to_many :locations
  has_many_hosts :dependent => :nullify
  has_many :organization_parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "OrganizationParameter"
  accepts_nested_attributes_for :organization_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true

  scope :completer_scope, lambda { |opts| my_organizations }

  scope :my_organizations, lambda {
      user = User.current
      if user.admin?
        conditions = { }
      else
        conditions = sanitize_sql_for_conditions([" (taxonomies.id in (?))", user.organization_ids])
      end
      where(conditions)
    }

  scoped_search :on => :label, :complete_value => :true, :default_order => true
  scoped_search :on => :name, :complete_value => :true

  # returns self and parent parameters as a hash
  def parameters include_source = false
    hash = {}
    ids = ancestor_ids
    ids << id unless new_record? or self.frozen?
    # need to pull out the organizations to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    orgs = ids.size == 1 ? [self] : Organization.includes(:organization_parameters).sort_by_ancestry(Organization.find(ids))
    orgs.each do |org|
      org.organization_parameters.each {|p| hash[p.name] = include_source ? {:value => p.value, :source => N_('organization').to_sym} : p.value }
    end
    hash
  end

  def dup
    new = super
    new.locations = locations
    new
  end

  def lookup_value_match
    "organization=#{label}"
  end

  def sti_name
    _("organization")
  end

end
