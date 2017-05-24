module ProxyAPI
  class Template < ProxyAPI::Resource
    def initialize args
      @url = args[:url] + "/unattended"
      super args
    end

    # returns the Template URL for this proxy
    def template_url
      if (response = parse(get("templateServer"))) && response["templateServer"].present?
        return response["templateServer"]
      end
    rescue Exception => e
      Foreman::Logging.exception("Failed to obtain template server from smart-proxy #{@url}", e)
      nil
    end
  end
end
