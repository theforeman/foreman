module HostAspects
  class Entry
    ATTRIBUTES = [:name, :model, :helper, :extension, :tabs]
    attr_accessor(*ATTRIBUTES)

    ATTRIBUTES.each do |attr|
      define_method "#{attr}_class".to_sym do
        sym = self.send(attr)
        to_class(sym)
      end
    end

    def initialize(aspect_name, aspect_model)
      self.name = to_name(aspect_name)
      self.model = to_model(aspect_model)
    end

    def add_helper(aspect_helper)
      self.helper = aspect_helper.try(:to_sym)
    end

    def add_tabs(tabs)
      raise ArgumentError, 'tabs should be a hash or a helper method symbol' unless tabs.is_a?(Hash) || tabs.is_a?(Symbol)
      self.tabs = tabs
    end

    def extend_model(extension_symbol)
      self.extension = extension_symbol.to_sym
    end

    private

    def to_name(aspect_name)
      aspect_name.to_sym
    end

    def to_model(aspect_model)
      aspect_model.try(:to_sym) || self.name.to_s.underscore.to_sym
    end

    private

    def to_class(symbol)
      symbol.to_s.camelize.constantize if symbol
    end
  end
end