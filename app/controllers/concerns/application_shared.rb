module ApplicationShared
  extend ActiveSupport::Concern

  include Foreman::Controller::Authentication
  include Foreman::Controller::Session
  include Foreman::ThreadSession::Cleaner
  include FindCommon

  def set_timezone
    default_timezone = Time.zone
    client_timezone  = User.current.try(:timezone) || cookies[:timezone]
    Time.zone        = client_timezone if client_timezone.present?
    yield
  ensure
    # Reset timezone for the next thread
    Time.zone = default_timezone
  end

  private

  # Get the allowed parameters from the Apipie documentation in the API controllers.
  def safe_params
    model_api_description = apipie_params.find { |param| param[:name] == controller_name.singularize }
    params.require(controller_name.singularize.to_sym).
      permit(*safe_attributes_from_api_description(model_api_description))
  end

  def safe_attributes_from_api_description(model_api_description)
    model_api_description[:params].map do |apipie_param|
      if param_group?(apipie_param)
        { apipie_param[:name].to_sym => build_safe_params(apipie_param[:params]) }
      else
        case apipie_param[:expected_type]
        when "array"
          { apipie_param[:name] => [] }
        when "hash"
          { apipie_param[:name] => {} }
        else
          apipie_param[:name].to_sym
        end
      end
    end
  end

  def param_group?(apipie_param)
    apipie_param[:params].present?
  end

  def apipie_params
    Apipie.app.get_method_description(apipie_class, action_name).to_json[:params]
  end

  def apipie_class
    "v2##{controller_name}"
  end
end
