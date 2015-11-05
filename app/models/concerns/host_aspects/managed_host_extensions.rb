require 'host_aspects'

module HostAspects
  module ManagedHostExtensions
    extend ActiveSupport::Concern

    included do
      HostAspects::ManagedHostExtensions.refresh_aspect_relations(self)
      after_save :clear_association_cache #should be removed after moving to rails 4. Fixes an issue with save! that breaks :inverse_of.

      def attributes
        hash = super

        # include all aspect attributes by default
        host_aspects_with_definitions.each do |aspect, aspect_definition|
          hash["#{aspect_definition.model}_attributes"] = aspect.attributes.reject { |key, _| %w(created_at updated_at).include? key }
        end
        hash
      end
    end

    def self.refresh_aspect_relations(klass)
      klass.class_eval do
        HostAspects.configuration.registered_aspects.values.each do |aspect_config|
          has_one aspect_config.model, :class_name => aspect_config.model_class.name, :foreign_key => :host_id, :inverse_of => :host
          accepts_nested_attributes_for aspect_config.model

          include aspect_config.extension_class if aspect_config.extension

          include_in_clone aspect_config.model
        end
      end
    end

    def host_aspects
      host_aspects_with_definitions.keys
    end

    def host_aspects_with_definitions
      Hash[(HostAspects.configuration.registered_aspects.values.map do |aspect_config|
        aspect = send(aspect_config.model)
        [aspect, aspect_config] if aspect
      end).compact]
    end
  end
end
