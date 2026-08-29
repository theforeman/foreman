module Oidc
  class HttpClient
    MAX_RESPONSE_SIZE = 1.megabyte
    TIMEOUT = 10

    def initialize(auth_source)
      @auth_source = auth_source
    end

    def get_json(url, headers = {})
      request_json(:get, url, :headers => headers)
    end

    def post_form(url, payload, headers = {})
      request_json(:post, url, :payload => payload, :headers => headers)
    end

    def validate_url!(url)
      uri = URI.parse(url.to_s)
      unless uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.nil? && uri.fragment.nil?
        raise Oidc::ConfigurationError, N_('OpenID Connect endpoints must be HTTPS URLs without credentials or fragments')
      end
      uri
    rescue URI::InvalidURIError => exception
      raise Oidc::ConfigurationError, N_('OpenID Connect endpoint is not a valid URL'), exception.backtrace
    end

    private

    attr_reader :auth_source

    def request_json(method, url, options = {})
      uri = validate_url!(url)
      request_options = {
        :method => method,
        :url => uri.to_s,
        :headers => { :accept => :json }.merge(options.fetch(:headers, {})),
        :max_redirects => 0,
        :open_timeout => TIMEOUT,
        :timeout => TIMEOUT,
        :verify_ssl => OpenSSL::SSL::VERIFY_PEER,
      }
      request_options[:payload] = options[:payload] if options.key?(:payload)
      store = Foreman::Util.ssl_cert_store(auth_source.cacert)
      request_options[:ssl_cert_store] = store if store

      response = RestClient::Request.execute(request_options)
      raise Oidc::AuthenticationError, N_('OpenID Connect provider response is too large') if response.body.bytesize > MAX_RESPONSE_SIZE

      parsed = JSON.parse(response.body)
      raise Oidc::AuthenticationError, N_('OpenID Connect provider returned an invalid response') unless parsed.is_a?(Hash)

      parsed
    rescue JSON::ParserError => exception
      raise Oidc::AuthenticationError, N_('OpenID Connect provider returned invalid JSON'), exception.backtrace
    rescue RestClient::ExceptionWithResponse => exception
      message = exception.response&.code ? "HTTP #{exception.response.code}" : exception.message
      raise Oidc::AuthenticationError.new(N_('OpenID Connect request failed: %s'), message)
    rescue RestClient::Exception, SocketError, SystemCallError, Timeout::Error => exception
      raise Oidc::AuthenticationError.new(N_('OpenID Connect request failed: %s'), exception.message)
    end
  end
end
