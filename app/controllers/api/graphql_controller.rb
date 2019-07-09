module Api
  class GraphqlController < ActionController::Base
    include Foreman::ThreadSession::Cleaner
    include Foreman::Controller::Timezone
    include Foreman::Controller::RequireSsl
    include Foreman::Controller::Session
    include Foreman::Controller::Authentication
    include Foreman::Controller::ApiCsrfProtection
    include Foreman::Controller::BruteforceProtection

    rescue_from Exception, with: :generic_exception if Rails.env.production?

    before_action :authenticate
    before_action :session_expiry, :update_activity_time
    around_action :set_timezone

    def execute
      result = if params[:_json]
                 execute_multiplexed_graphql_query
               else
                 execute_single_graphql_query
               end

      render json: result
    end

    def api_request?
      true
    end

    def authenticate
      if bruteforce_attempt?
        log_bruteforce
        render_error('Bruteforce attempt.', status: :unauthorized)
        return false
      end

      authenticated = super

      count_login_failure if available_sso.present? && !authenticated

      authenticated
    end

    private

    def execute_multiplexed_graphql_query
      queries = params[:_json].map do |param|
        {
          query: param['query'],
          operation_name: param['operationName'],
          variables: ensure_hash(param['variables']),
          context: graphql_context,
        }
      end
      ForemanGraphqlSchema.multiplex(queries)
    end

    def execute_single_graphql_query
      ForemanGraphqlSchema.execute(
        params[:query],
        variables: variables,
        context: graphql_context
      )
    end

    def graphql_context
      {
        current_user: User.current,
        request_id: request.uuid,
        request_ip: request.ip,
      }
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
      when ActionController::Parameters
        ambiguous_param.to_unsafe_h
      when Hash
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    rescue JSON::ParserError
      raise ArgumentError, "Could not parse JSON data in #{ambiguous_param}"
    end

    def generic_exception(exception)
      Foreman::Logging.exception('Action failed', exception)
      render_error
    end

    def render_error(error = 'An error occured.', options = {})
      options[:status] ||= :internal_server_error
      render options.merge(json: {error: error})
    end
  end
end
