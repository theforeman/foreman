module ProxyAPI
  class ProxyException < ::Foreman::WrappedException
    attr_reader :url

    def initialize(url, exception, message, *params)
      super(exception, message, *params)
      @url = url
    end

    def message
      super + proxy_exception_response(exception) +
        ' ' + _('for proxy') + ' ' + url
    end

    private

    def proxy_exception_response(exception)
      return '' unless exception.respond_to?(:response)
      ": #{exception.response}"
    end
  end
end
