# frozen_string_literal: true

module ForemanRegister
  class ApplicationController < ::ApplicationController
    def resource_class
      self.class.to_s.sub(/Controller$/, '').singularize.constantize
    end

    def resource_name(resource = resource_class)
      resource.name.downcase.singularize
    end

    def controller_name
      "foreman_register_#{super}"
    end
  end
end
