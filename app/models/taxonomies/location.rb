class Location < Taxonomy
  include Foreman::ThreadSession::LocationModel

  has_and_belongs_to_many :organizations
  has_many_hosts :dependent => :nullify

  scope :completer_scope, lambda { |opts| my_locations }

  scope :my_locations, lambda {
    conditions = if User.current.admin?
      { }
    else
      sanitize_sql_for_conditions([" (taxonomies.id in (?)) ", User.current.location_ids])
    end
    where(conditions).reorder('type, name')
  }

  def dup
    new = super
    new.organizations = organizations
    new
  end

end
