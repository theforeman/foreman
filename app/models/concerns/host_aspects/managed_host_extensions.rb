require 'host_aspects'

module HostAspects
  module ManagedHostExtensions
    extend ActiveSupport::Concern

    included do
      HostAspects::ManagedHostExtensions.refresh_aspect_relations(self)

      has_many :host_aspects, :foreign_key => :host_id, :inverse_of => :host do
        def [](subject)
          where(:aspect_subject => subject).first ||
          find { |aspect| aspect.aspect_subject == subject } ||
          build(:aspect_subject => subject)
        end
      end
      accepts_nested_attributes_for :host_aspects

      def attributes
        hash = super

        # include all aspect attributes by default
        host_aspects.each do |aspect|
          aspect_definition = HostAspects.configuration[aspect.aspect_subject]
          obj = send(aspect_definition.model)
          hash["#{aspect_definition.model}_attributes"] = obj.attributes.reject { |key, _| %w('id', 'created_at', 'updated_at').include? key }
        end
        hash
      end
    end

    def self.refresh_aspect_relations(klass)
      klass.class_eval do
        HostAspects.configuration.registered_aspects.values.each do |aspect_config|
          include aspect_config.extension_class if aspect_config.extension
          has_one aspect_config.model, :class_name => aspect_config.model_class.name, :foreign_key => :host_id, :inverse_of => :host

          define_method "#{aspect_config.model}=" do |aspect|
            super(aspect)

            notify_aspect_registry(aspect, aspect_config.subject)
          end

          define_method "build_#{aspect_config.model}"do |*attributes|
            aspect = super(*attributes)

            notify_aspect_registry(aspect, aspect_config.subject)
            aspect
          end

          define_method "create_#{aspect_config.model}" do |*attributes|
            aspect = super(*attributes)

            notify_aspect_registry(aspect, aspect_config.subject)
            aspect
          end

          define_method "create_#{aspect_config.model}!" do |*attributes|
            aspect = super(*attributes)

            notify_aspect_registry(aspect, aspect_config.subject)
            aspect
          end
        end
      end
    end

    private

    def notify_aspect_registry(aspect_model, subject)
      entry = host_aspects[subject]
      entry.execution_model = aspect_model
    end
  end
end
