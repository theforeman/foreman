module ProxyAPI

  class Resource
    attr_reader :url

    def initialize(args)
      raise("Must provide a protocol and host when initialising a smart-proxy connection") unless (url =~ /^http/)

      # Each request is limited to 60 seconds
      @connect_params = {:timeout => 60, :open_timeout => 10, :headers => { :accept => :json },
                        :user => args[:user], :password => args[:password]}

      # We authenticate only if we are using SSL
      if url.match(/^https/i)
        cert         = Setting[:ssl_certificate]
        ca_cert      = Setting[:ssl_ca_file]
        hostprivkey  = Setting[:ssl_priv_key]

        @connect_params.merge!(
          :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(File.read(cert)),
          :ssl_client_key   =>  OpenSSL::PKey::RSA.new(File.read(hostprivkey)),
          :ssl_ca_file      =>  ca_cert,
          :verify_ssl       =>  OpenSSL::SSL::VERIFY_PEER
        ) unless Rails.env == "test"
      end
    end

    protected

    attr_reader :connect_params

    def resource
      # Required in order to ability to mock the resource
      @resource ||= RestClient::Resource.new(url, connect_params)
    end

    # Sets the credentials in the connection parameters, creates new resource when called
    # Since there is now other way to set the credential
    def set_credentials(username, password)
      @connect_params[:user]     = username
      @connect_params[:password] = password
      @resource                  = nil
    end

    def logger; Rails.logger; end

    private
    # Decodes the JSON response if no HTTP error has been detected
    # If an HTTP error is received then the error message is saves into @error
    # Returns: Response, if the operation is GET, or true for POST, PUT and DELETE.
    #      OR: false if a HTTP error is detected
    # TODO: add error message handling
    def parse response
      if response and response.code >= 200 and response.code < 300
        return response.body.present? ? JSON.parse(response.body) : true
      else
        false
      end
    rescue => e
      logger.warn "Failed to parse response: #{response} -> #{e}"
      false
    end

    # Perform GET operation on the supplied path
    def get path = nil, payload = {}
      # This ensures that an extra "/" is not generated
      if path
        resource[URI.escape(path)].get payload
      else
        resource.get payload
      end
    end

    # Perform POST operation with the supplied payload on the supplied path
    def post payload, path = ""
      resource[path].post payload
    end

    # Perform PUT operation with the supplied payload on the supplied path
    def put payload, path = ""
      resource[path].put payload
    end

    # Perform DELETE operation on the supplied path
    def delete path
      resource[path].delete
    end
  end

end
