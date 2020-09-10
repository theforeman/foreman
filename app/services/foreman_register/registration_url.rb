# frozen_string_literal: true

module ForemanRegister
  class RegistrationUrl
    attr_reader :host

    delegate :registration_token, to: :host

    def initialize(host:)
      @host = host
    end

    def url
      uri = URI.parse(Setting[:foreman_url])
      uri.scheme = SETTINGS[:require_ssl] ? 'https' : 'http'
      uri.path = Rails.application.routes.url_helpers.register_foreman_register_hosts_path
      uri.query = "token=#{registration_token}"
      uri.to_s
    end
  end
end
