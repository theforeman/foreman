object false
child(:links => "links") do

  # gather index methods of resources
  index_method_description_apis = Apipie.app.resource_descriptions.map do |name, resource_description|
    if (description = Apipie.method_descriptions["#{name}#index"])
      description.apis.first
    end
  end.compact

  # add additional actions
  %w(home#status).each do |additional_action|
    if (description = Apipie.app.method_descriptions[additional_action]) and
        (api = description.apis.first)
      index_method_description_apis << api
    end
  end

  # render links
  index_method_description_apis.each do |api|
    url, description = api.api_url, api.short_description
    node(description) { url }
  end
end
