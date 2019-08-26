module UI
  class HostDescription
    CUSTOMIZATION_POINTS = [:overview_fields, :overview_buttons, :multiple_actions, :title_actions]

    def self.reduce_providers(customization_point)
      UI.host_descriptions.map(&customization_point).flatten.compact
    end

    attr_reader(*CUSTOMIZATION_POINTS)

    CUSTOMIZATION_POINTS.each do |customization_point|
      define_method "#{customization_point}_provider" do |method_sym|
        value = instance_variable_get("@#{customization_point}") || []
        value << method_sym
        instance_variable_set("@#{customization_point}", value)
      end
    end
  end
end
