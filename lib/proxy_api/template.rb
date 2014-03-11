module ProxyAPI
  class Template < ProxyAPI::Resource
    def initialize args
      @url     = args[:url] + "/unattended"
      super args
    end

    # returns the Template URL for this proxy
    def template_url
      if (response = parse(get("templateServer"))) and response["templateServer"].present?
        return response["templateServer"]
      end
      false
    rescue RestClient::ResourceNotFound
      nil
    end

  end
end
