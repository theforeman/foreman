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

  # This scoped search definition intentionally duplicates app/models/concerns/nested_ancestry_common.rb
  # It's a temporary fix for scoped_search's issue with completing search strings for inherited attributes
  # See http://projects.theforeman.org/issues/4613 for details
  scoped_search :on => :title, :complete_value => :true, :default_order => true
  scoped_search :on => :name, :complete_value => :true

  # returns self and parent parameters as a hash
  def parameters include_source = false
    hash = {}
    ids = ancestor_ids
    ids << id unless new_record? or self.frozen?
    # need to pull out the locations to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    locs = ids.size == 1 ? [self] : Location.includes(:location_parameters).sort_by_ancestry(Location.find(ids))
    locs.each do |loc|
      loc.location_parameters.each {|p| hash[p.name] = include_source ? {:value => p.value, :source => N_('location').to_sym} : p.value }
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
