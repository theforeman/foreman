class Organization < Taxonomy
  include Foreman::ThreadSession::OrganizationModel

  has_and_belongs_to_many :locations

  def to_param
    "#{id.to_s.parameterize}"
  end

  def to_label
    name.capitalize
  end
end
