class Location < Taxonomy
  include Foreman::ThreadSession::LocationModel

  has_and_belongs_to_many :organizations
  has_many_hosts :dependent => :nullify

  has_many :location_parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "LocationParameter"
  accepts_nested_attributes_for :location_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true

  scope :completer_scope, lambda { |opts| my_locations }

  scope :my_locations, lambda {
        user = User.current
        if user.admin?
          conditions = { }
        else
          conditions = sanitize_sql_for_conditions([" (taxonomies.id in (?))", user.location_ids])
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
    # need to pull out the locations to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    locs = ids.size == 1 ? [self] : Location.includes(:location_parameters).sort_by_ancestry(Location.find(ids))
    locs.each do |hg|
      hg.location_parameters.each {|p| hash[p.name] = include_source ? {:value => p.value, :source => :location} : p.value }
    end
    hash
  end

  def dup
    new = super
    new.organizations = organizations
    new
  end

  def lookup_value_match
    "location=#{label}"
  end

  def sti_name
    _("location")
  end

end
