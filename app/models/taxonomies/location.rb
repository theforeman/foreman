class Location < Taxonomy
  include Foreman::ThreadSession::LocationModel
  include Parameterizable::ByIdName

  has_and_belongs_to_many :organizations, :join_table => "locations_organizations"
  has_many_hosts :dependent => :nullify

  has_many :location_parameters, :class_name => 'LocationParameter', :foreign_key => :reference_id, :dependent => :destroy, :inverse_of => :location
  has_many :default_users,       :class_name => 'User',              :foreign_key => :default_location_id
  accepts_nested_attributes_for :location_parameters, :allow_destroy => true
  include ParameterValidators

  scope :completer_scope, lambda { |opts| my_locations }

  scope :my_locations, lambda {
    conditions = User.current.admin? ? {} : sanitize_sql_for_conditions([" (taxonomies.id in (?))", User.current.location_and_child_ids])
    where(conditions)
  }

  # returns self and parent parameters as a hash
  def parameters(include_source = false)
    hash = {}
    ids = ancestor_ids
    ids << id unless new_record? or self.frozen?
    # need to pull out the locations to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    locs = ids.size == 1 ? [self] : Location.sort_by_ancestry(Location.includes(:location_parameters).find(ids))
    locs.each do |loc|
      loc.location_parameters.each {|p| hash[p.name] = include_source ? {:value => p.value, :source => N_('location').to_sym, :source_name => loc.title} : p.value }
    end
    hash
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
