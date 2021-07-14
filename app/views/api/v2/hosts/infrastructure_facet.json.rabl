node(:infrastructure_facet) do
  facet = @object.infrastructure_facet
  {
    :foreman => facet&.foreman || false,
    :smart_proxy_id => facet&.smart_proxy_id,
  }
end
