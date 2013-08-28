class Organization < Taxonomy
  include Foreman::ThreadSession::OrganizationModel

  has_and_belongs_to_many :locations
  has_many_hosts :dependent => :nullify

  scope :completer_scope, lambda { |opts| my_organizations }

  scope :my_organizations, lambda {
    conditions = if User.current.admin?
      { }
    else
      sanitize_sql_for_conditions([" (taxonomies.id in (?))", User.current.organization_ids])
    end
    where(conditions).reorder('type, name')
  }

  def dup
    new = super
    new.locations = locations
    new
  end
end
