module Foreman
  class SettingManager
    class << self
      # Holds all the setting definitions for application
      def settings
        @settings ||= {}
      end

      # Holds all setting categories with their labels
      def categories
        @categories ||= { 'general' => N_('General') }
      end

      def define(context_name, &block)
        new(context_name).instance_eval(&block)
      end
    end

    def initialize(context_name)
      @context_name = context_name
    end

    def category(category_name, category_label = nil, &block)
      self.class.categories[category_name.to_s] ||= category_label
      CategoryMapper.new(@context_name, category_name.to_s).instance_eval(&block)
    end

    class CategoryMapper
      attr_reader :context_name, :category_name

      def initialize(context_name, category_name)
        @context_name = context_name
        @category_name = category_name
      end

      def storage
        SettingManager.settings
      end

      # Adds setting definition
      #
      # ===== Example
      #
      #   SettingManager.define(:puppet) do
      #     category(:cfgmgmt, N_('Configuration Management')) do
      #       setting(:use_cooler_puppet,
      #               default: true,
      #               description: N_('Use Puppet that goes to 11'),
      #               full_name: N_('Use shiny puppet'),
      #               encrypt: true)
      #     end
      #   end
      #
      def setting(name, default:, description:, full_name: nil, value: nil, collection: nil, encrypted: false, **options)
        raise ::Foreman::Exception.new(N_("Setting '%s' is already defined, please avoid collisions"), name) if storage.key?(name.to_s)
        storage[name.to_s] = {
          context: context_name,
          category: category_name,
          default: default,
          description: description,
          full_name: full_name,
          value: value,
          collection: collection,
          encrypted: encrypted,
          options: options,
        }
      end
    end
  end
end
