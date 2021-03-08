module Resolvers
  module ProvisioningTemplate
    class Path < Resolvers::BaseResolver
      type String, null: false

      def resolve
        Rails.application.routes.url_helpers.edit_provisioning_template_path(object)
      end
    end
  end
end
