require 'securerandom'
require 'rest-client-patch'

module ProxyAPI
  class Resource
    attr_reader :url

    def initialize(args)
      raise("Must provide a protocol and host when initialising a smart-proxy connection") unless (url =~ /^http/)

      @connect_params = {:timeout => Setting[:proxy_request_timeout], :open_timeout => 10,
                         :headers => { :accept => :json, :x_request_id => request_id },
                         :user => args[:user], :password => args[:password]}

      # We authenticate only if we are using SSL
      @connect_params.merge!(ssl_auth_params) if url =~ /^https/i && !Rails.env.test?
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

    def logger
      Foreman::Logging.logger('proxy')
    end

    private

    # Decodes the JSON response if no HTTP error has been detected
    # If an HTTP error is received then the error message is saves into @error
    # Returns: Response, if the operation is GET, or true for POST, PUT and DELETE.
    #      OR: false if a HTTP error is detected
    # TODO: add error message handling
    def parse(response)
      if response && response.code >= 200 && response.code < 300
        return response.body.present? ? JSON.parse(response.body) : true
      else
        false
      end
    rescue => e
      logger.warn "Failed to parse response: #{response} -> #{e}"
      false
    end

    # Perform GET operation on the supplied path
    def get(path = nil, payload = {})
      with_logger do
        # This ensures that an extra "/" is not generated
        if path
          resource[URI.escape(path)].get payload
        else
          resource.get payload
        end
      end
    end

    # Perform POST operation with the supplied payload on the supplied path
    def post(payload, path = "")
      logger.debug("POST request payload: #{payload}")
      with_logger do
        resource[path].post payload
      end
    end

    # Perform PUT operation with the supplied payload on the supplied path
    def put(payload, path = "")
      logger.debug("PUT request payload: #{payload}")
      with_logger do
        resource[path].put payload
      end
    end

    # Perform DELETE operation on the supplied path
    def delete(path)
      with_logger do
        resource[path].delete
      end
    end

    def with_logger
      old_logger = RestClient.log
      RestClient.log = RestClientLogger.new(logger)
      yield
    ensure
      RestClient.log = old_logger
    end

    def request_id
      ::Logging.mdc['session_safe'] || SecureRandom.hex(32)
    end

    def ssl_auth_params
      cert         = Setting[:ssl_certificate]
      ca_cert      = Setting[:ssl_ca_file]
      hostprivkey  = Setting[:ssl_priv_key]

      raw_cert     = File.read(cert)

      # split the certificate data, to extract certificate chains if they exists
      cert_end  = '-----END CERTIFICATE-----'
      cert_list = raw_cert.split(/(?<=#{cert_end})/)
                   .reject { |s| s.strip.empty? }
                   .map{ |cert_data| OpenSSL::X509::Certificate.new(cert_data) }

      {
        :ssl_client_cert  =>  cert_list[0],
        :ssl_client_key   =>  OpenSSL::PKey::RSA.new(File.read(hostprivkey)),
        :ssl_ca_file      =>  ca_cert,
        :extra_chain_cert =>  cert_list.drop(1),
        :verify_ssl       =>  OpenSSL::SSL::VERIFY_PEER
      }
    end
  end

  class RestClientLogger
    def initialize(logger)
      @logger = logger
    end

    def <<(msg)
      @logger.debug(msg.chomp)
    end
  end
end
