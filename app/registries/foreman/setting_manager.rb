require 'foreman/util'

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

      def validations
        @validations ||= Validations.new
      end
    end

    def initialize(context_name)
      @context_name = context_name
    end

    def category(category_name, category_label = nil, &block)
      self.class.categories[category_name.to_s] ||= category_label
      CategoryMapper.new(@context_name, category_name.to_s).instance_eval(&block)
    end

    class Validations
      def initialize
        @validates = {}
        @validates_with = {}
      end

      def setup!
        @validates.each do |name, validations_ary|
          validations_ary.each do |validations|
            _wrap_validation_if(name, validations)
            Setting.validates(:value, validations)
          end
        end
        @validates_with.each do |name, validations_ary|
          validations_ary.each do |(args, block)|
            options = args.extract_options!
            _wrap_validation_if(name, options)
            options[:attributes] = [:value]
            args << options
            Setting.validates_with(*args, &block)
          end
        end
      end

      def validates(name, validations, **opts)
        if validations.is_a?(Proc)
          validates_with name, ValueLambdaValidator, opts.merge(proc: validations)
        else
          @validates[name] ||= []
          @validates[name] << validations
        end
      end

      def validates_with(name, *args, &block)
        @validates_with[name] ||= []
        @validates_with[name] << [args, block]
      end

      private

      def _wrap_validation_if(setting_name, options)
        options[:if] = [
          ->(setting) { setting.name == setting_name.to_s },
          *options[:if],
        ]
      end
    end

    class ValueLambdaValidator < ActiveModel::Validator
      def validate(record)
        return true if options[:allow_blank] && record.value.blank?
        record.errors.add(:value, :invalid, message: _(options[:message])) unless options[:proc].call(record.value)
      end
    end

    class CategoryMapper
      include Foreman::Util

      attr_reader :context_name, :category_name

      def initialize(context_name, category_name)
        @context_name = context_name
        @category_name = category_name
      end

      def storage
        SettingManager.settings
      end

      def available_types
        [:boolean, :integer, :float, :string, :text, :hash, :array]
      end

      # Adds setting definition
      #
      # ===== Example
      #
      #   SettingManager.define(:puppet) do
      #     category(:cfgmgmt, N_('Configuration Management')) do
      #       setting(:use_cooler_puppet,
      #               type: :boolean,
      #               default: true,
      #               description: N_('Use Puppet that goes to 11'),
      #               full_name: N_('Use shiny puppet'),
      #               encrypted: true,
      #               validate: /^cool/)
      #     end
      #   end
      #
      def setting(name, default:, description:, type:, full_name: nil, value: nil, collection: nil, encrypted: false, validate: nil, **options)
        raise ::Foreman::Exception.new(N_("Setting '%s' is already defined, please avoid collisions"), name) if storage.key?(name.to_s)
        raise ::Foreman::Exception.new(N_("Setting '%s' has an invalid type definition. Please use a valid type."), name) unless available_types.include?(type)
        storage[name.to_s] = {
          context: context_name,
          category: category_name,
          type: type,
          default: default,
          description: description,
          full_name: full_name,
          value: value,
          collection: collection,
          encrypted: encrypted,
          options: options,
        }
        _inline_validates(name, validate) if validate
        storage[name.to_s]
      end

      def _inline_validates(name, validations)
        if validations.is_a?(Regexp)
          validations = { format: { with: validations } }
        elsif validations.is_a?(Symbol)
          validations = { validations => true }
        end
        validates(name, validations)
      end

      def validates(name, validations, **opts)
        SettingManager.validations.validates(name, validations, **opts)
      end

      def validates_with(name, *args, &block)
        SettingManager.validations.validates_with(name, *args, &block)
      end
    end
  end
end

Rails.application.config.to_prepare do
  Foreman::SettingManager.validations.setup!
end
