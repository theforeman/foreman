object @config_template

attributes :name, :template, :snippet, :audit_comment, :id

node do |template|
  unless template.snippet?
    child :template_kind do
      attributes :name, :id
    end
  end
end
