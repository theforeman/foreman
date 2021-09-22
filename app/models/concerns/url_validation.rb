module UrlValidation
  extend ActiveSupport::Concern

  def is_http_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP || URI::HTTPS) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  module ClassMethods
    def validate_is_http_url(attr)
      is_http_url?(send(attr))
    end
  end
end
