class Organization < Taxonomy
  include Foreman::ThreadSession::OrganizationModel

  has_and_belongs_to_many :locations
  has_many :hosts
  before_destroy EnsureNotUsedBy.new(:hosts)

  scope :completer_scope, lambda { my_organizations }

  scope :my_organizations, lambda {
      user = User.current
      if user.admin?
        conditions = { }
      else
        conditions = sanitize_sql_for_conditions([" (taxonomies.id in (?))", user.organizations.map(&:id)])
      end
      where(conditions).reorder('type, name')
    }
end
