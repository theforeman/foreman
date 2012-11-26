class Location < Taxonomy
  include Foreman::ThreadSession::LocationModel

  has_and_belongs_to_many :organizations
  has_many :hosts
  before_destroy EnsureNotUsedBy.new(:hosts)

  scope :completer_scope, lambda { my_locations }

  scope :my_locations, lambda {
        user = User.current
        if user.admin?
          conditions = { }
        else
          conditions = sanitize_sql_for_conditions([" (taxonomies.id in (?))", user.locations.map(&:id)])
        end
        where(conditions).reorder('type, name')
      }
end
