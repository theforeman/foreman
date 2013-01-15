object false
child(:links => "links") do

  # gather index methods of resources
  index_method_description_apis = Apipie.app.resource_descriptions[Apipie.configuration.default_version].map do |name, resource_description|
    if (description = Apipie.app["#{name}#index"])
      description.method_apis_to_json.first
    end
  end.compact

  # add additional actions
  %w(home#status).each do |additional_action|
    if (description = Apipie.app[additional_action]) and
        (api = description.method_apis_to_json.first)
      index_method_description_apis << api
    end
  end

  # render links
  index_method_description_apis.each do |api|
    url, description = api[:api_url], api[:short_description]
    node(description.chomp(".")) { url }
  end
end
