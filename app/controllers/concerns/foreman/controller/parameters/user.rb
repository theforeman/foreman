module Foreman::Controller::Parameters::User
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix
  include Foreman::Controller::Parameters::UserMailNotification

  class_methods do
    def user_params_filter
      Foreman::ParameterFilter.new(::User).tap do |filter|
        filter.permit :default_location_id,
          :default_organization_id,
          :firstname,
          :lastname,
          :locale,
          :mail,
          :mail_enabled,
          :password,
          :password_confirmation,
          :timezone,
          :user_mail_notifications_attributes => [user_mail_notification_params_filter]

        filter.permit do |ctx|
          ctx.permit :admin if ctx.currently_admin? && (ctx.ui? || ctx.api?)
        end

        filter.permit do |ctx|
          if !ctx.editing_self? && (ctx.ui? || ctx.api?)
            ctx.permit :auth_source, :auth_source_id, :auth_source_name,
              :login,
              :roles => [], :role_ids => [], :role_names => []
          end
        end

        add_taxonomix_params_filter(filter)
      end
    end
  end

  def user_params
    self.class.user_params_filter.filter_params(params, parameter_filter_context)
  end

  class Context < Foreman::ParameterFilter::Context
    def initialize(type, controller_name, action, editing_self)
      super(type, controller_name, action)
      @editing_self = editing_self
    end

    def editing_self?
      @editing_self
    end

    def currently_admin?
      !!User.current.try(:admin?)
    end
  end
end
