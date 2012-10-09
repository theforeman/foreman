class Organization < Taxonomy
  include Foreman::ThreadSession::OrganizationModel

  def to_param
    "#{id.to_s.parameterize}"
  end

  def to_label
    name.capitalize
  end
end
