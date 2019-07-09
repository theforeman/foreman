object false

node(:message) do
  _("Resource %{resource_name} not found by id '%{id}'") % {
    :resource_name => controller.resource_name,
    :id => controller.params[:id],
  }
end
