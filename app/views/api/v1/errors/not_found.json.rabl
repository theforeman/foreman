object false

node(:message) { "Resource #{controller.resource_name} not found by id '#{controller.params[:id]}'" }
