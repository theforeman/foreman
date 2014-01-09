class Organization < Taxonomy
  include Foreman::ThreadSession::OrganizationModel

  has_and_belongs_to_many :locations
  has_many_hosts :dependent => :nullify
  has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "OrganizationParameter"
  accepts_nested_attributes_for :parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true

  scope :completer_scope, lambda { |opts| my_organizations }

  scope :my_organizations, lambda {
      user = User.current
      if user.admin?
        conditions = { }
      else
        conditions = sanitize_sql_for_conditions([" (taxonomies.id in (?))", user.organization_ids])
      end
      where(conditions).reorder('type, name')
    }

  def dup
    new = super
    new.locations = locations
    new
  end
end
