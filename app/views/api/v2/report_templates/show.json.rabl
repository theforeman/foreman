object @report_template

extends "api/v2/report_templates/main"

attributes :template

node do |report_template|
  partial("api/v2/taxonomies/children_nodes", :object => report_template)
end
