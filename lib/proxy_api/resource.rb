require 'securerandom'

module ProxyAPI
  class Resource
    include Foreman::TelemetryHelper
    attr_reader :url

    def initialize(args)
      raise("Must provide a protocol and host when initialising a smart-proxy connection") unless (url =~ /^http/)

      @connect_params = {
        :timeout => Setting[:proxy_request_timeout],
        :headers => {
          :accept => :json,
          :x_request_id => request_id,
          :x_session_id => session_id,
        },
        :user => args[:user],
        :password => args[:password],
      }

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
      telemetry_increment_counter(:proxy_api_response_code, 1, code: response.code) if response&.code
      if response && response.code >= 200 && response.code < 300
        response.body.present? ? JSON.parse(response.body) : true
      else
        false
      end
    rescue => e
      logger.warn "Failed to parse response: #{response} -> #{e}"
      false
    end

    # Perform GET operation on the supplied path
    def get(path = nil, payload = {})
      query = payload.delete(:query)
      Foreman::Deprecation.deprecation_warning("3.3", "passing additional headers to ProxyApi resource GET action") unless payload.empty?
      final_uri = path || ""
      if query
        raise SyntaxError, 'path must be specified if the query does' unless path
        query = URI.encode_www_form(query) unless query.is_a?(String)
        final_uri += "?#{query}"
      end
      with_logger do
        telemetry_duration_histogram(:proxy_api_duration, :ms, method: 'get') do
          # This ensures that an extra "/" is not generated
          if path
            resource[final_uri].get payload
          else
            resource.get payload
          end
        end
      end
    end

    # Perform POST operation with the supplied payload on the supplied path
    def post(payload, path = "")
      logger.debug("POST request payload: #{payload}")
      with_logger do
        telemetry_duration_histogram(:proxy_api_duration, :ms, method: 'post') do
          resource[path].post payload
        end
      end
    end

    # Perform PUT operation with the supplied payload on the supplied path
    def put(payload, path = "")
      logger.debug("PUT request payload: #{payload}")
      with_logger do
        telemetry_duration_histogram(:proxy_api_duration, :ms, method: 'put') do
          resource[path].put payload
        end
      end
    end

    # Perform DELETE operation on the supplied path
    def delete(path)
      with_logger do
        telemetry_duration_histogram(:proxy_api_duration, :ms, method: 'delete') do
          resource[path].delete
        end
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
      ::Logging.mdc['request'] || SecureRandom.uuid
    end

    def session_id
      ::Logging.mdc['session'] || SecureRandom.uuid
    end

    def ssl_auth_params
      cert         = Setting[:ssl_certificate]
      ca_cert      = Setting[:ssl_ca_file]
      hostprivkey  = Setting[:ssl_priv_key]

      {
        :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(File.read(cert)),
        :ssl_client_key   =>  OpenSSL::PKey::RSA.new(File.read(hostprivkey)),
        :ssl_ca_file      =>  ca_cert,
        :verify_ssl       =>  OpenSSL::SSL::VERIFY_PEER,
      }
    rescue StandardError => exception
      msg = N_("Unable to read SSL certification or key for proxy communication, check settings for ssl_certificate, ssl_ca_file and ssl_priv_key and ensure they are readable by the foreman user.")
      Foreman::Logging.exception(msg, exception)
      raise Foreman::WrappedException.new(exception, msg)
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
