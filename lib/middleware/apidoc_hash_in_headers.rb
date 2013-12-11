module Middleware
  class ApidocHashInHeaders
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers.merge!( 'Apipie-Apidoc-Hash' => Rails.configuration.apipie_apidoc_hash )
      return [status, headers, body]
    end
  end
end
