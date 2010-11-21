module ConfigTemplatesHelper
  def combination template
    template.template_combinations.map do |comb|
      str = []
      str << (comb.hostgroup_id.nil? ? "NONE" : comb.hostgroup.to_s)
      str << (comb.environment_id.nil? ? "NONE" : comb.environment.to_s)
      str.join(" / ")
    end.to_sentence
  end
end
