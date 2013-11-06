module Middleware
  class CatchJsonParseErrors
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        @app.call(env)
      rescue MultiJson::LoadError => error
        if env['HTTP_ACCEPT'] =~ /application\/json/
          error_output = "There was a problem in the JSON you submitted: #{error}"
          return [
            400, { "Content-Type" => "application/json" },
            [{ :status => 400, :error => error_output }.to_json]
          ]
        else
          raise error
        end
      end
    end
  end
end
