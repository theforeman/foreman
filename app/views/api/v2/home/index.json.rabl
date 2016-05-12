object false
child(:links => "links") do
  Apipie.app.resource_descriptions['v2'].map do |name, resource_description|
    object false
    child(:resource => name) do
      resource_description.method_descriptions.each do |method_description|
        api = method_description.method_apis_to_json.first
        url, description = api[:api_url], api[:short_description]
        node(description.chomp(".")) { url } if api && url && description
      end
    end
  end
end
