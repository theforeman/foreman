class Tenant < Taxonomy
  def to_param
    "#{id.to_s.parameterize}"
  end

  def to_label
    name.capitalize
  end
end
