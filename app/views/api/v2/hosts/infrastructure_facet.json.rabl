node(:infrastructure_facet) do
  facet = @object.infrastructure_facet
  {
    :foreman_instance => facet&.foreman_instance || false,
    :smart_proxy_id => facet&.smart_proxy_id,
  }
end
