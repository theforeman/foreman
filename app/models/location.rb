class Location < Taxonomy
  include Foreman::ThreadSession::LocationModel

  has_and_belongs_to_many :organizations
  has_many :hosts

  def to_param
    "#{id.to_s.parameterize}"
  end

  def to_label
    name.capitalize
  end

  scope :my_locations, lambda {
        user = User.current
        if user.admin?
          conditions = { }
        else
          #todo: rewrite this
          conditions = sanitize_sql_for_conditions([" (locations.id in (?))", user.locations.map(&:id)])
          conditions.sub!(/\s*\(\)\s*/, "")
          conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
          conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
        end
        where(conditions).reorder('type, name')
      }
end
