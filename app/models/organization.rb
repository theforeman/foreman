class Organization < Taxonomy
  include Foreman::ThreadSession::OrganizationModel

  has_and_belongs_to_many :locations
  has_many :hosts

  def to_param
    "#{id.to_s.parameterize}"
  end

  def to_label
    name.capitalize
  end

  scope :my_orgs, lambda {
      user = User.current
      if user.admin?
        conditions = { }
      else
        #todo: rewrite this
        conditions = sanitize_sql_for_conditions([" (organizations.id in (?))", user.organizations.map(&:id)])
        conditions.sub!(/\s*\(\)\s*/, "")
        conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
        conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
      end
      where(conditions).reorder('type, name')
    }
end
