module Api
  class GraphqlController < ActionController::Base
    force_ssl :if => :require_ssl?
    rescue_from Exception, :with => :generic_exception if Rails.env.production?

    before_action :set_current_user
    around_action :set_timezone

    def execute
      result = ForemanGraphqlSchema.execute(params[:query],
                                            variables: variables,
                                            context: {
                                              current_user: User.current
                                            })
      render json: result
    end

    private

    def set_current_user
      @current_user = begin
        payload = jwt_token.decode || {}
        user_id = payload['user_id']
        User.unscoped.find_by(id: user_id) if user_id
      rescue JWT::DecodeError
        nil
      end
      User.current = @current_user
    end

    def jwt_token
      @jwt_token ||= begin
        token = request.headers.fetch('Authorization', '')
        JwtToken.new(token)
      end
    end

    def variables
      ensure_hash(params[:variables])
    end

    def ensure_hash(ambiguous_param)
      case ambiguous_param
      when String
        if ambiguous_param.present?
          ensure_hash(JSON.parse(ambiguous_param))
        else
          {}
        end
      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end

    def generic_exception(exception)
      Foreman::Logging.exception("Action failed", exception)
      render json: "{ 'error': 500 }", :status => :internal_server_error
    end

    def set_timezone
      default_timezone = Time.zone
      client_timezone  = User.current.try(:timezone)
      Time.zone = client_timezone if client_timezone.present?
      yield
    ensure
      # Reset timezone for the next thread
      Time.zone = default_timezone
    end

    def require_ssl?
      SETTINGS[:require_ssl]
    end
  end
end
