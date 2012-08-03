object false

node(:message) { "Resource #{controller.resource_name} not found by #{locals[:finder]} with value '#{locals[:key]}'" }