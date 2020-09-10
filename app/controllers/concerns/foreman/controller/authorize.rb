module Foreman::Controller::Authorize
  extend ActiveSupport::Concern
  included do
    delegate :authorized_for, :authorizer, :can_create?, to: :helpers
  end
end
