object @report_template

extends "api/v2/report_templates/main"

attributes :template, :default, :snippet, :locked, :cloned_from_id

node do |report_template|
  partial("api/v2/taxonomies/children_nodes", :object => report_template)
end
