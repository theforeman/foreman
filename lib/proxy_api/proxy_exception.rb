module ProxyAPI
  class ProxyException < ::Foreman::WrappedException
    attr_reader :url

    def initialize(url, exception, message, *params)
      super(exception, message, *params)
      @url = url
    end

    def message
      super + ' ' + _('for proxy') + ' ' + url
    end
  end
end
