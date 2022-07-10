module UI
  class HostgroupDescription
    CUSTOMIZATION_POINT = [:hostgroup_actions]

    def self.reduce_provider(customization_point)
      UI.hostgroup_descriptions.map(&customization_point).flatten.compact
    end

    attr_reader(*CUSTOMIZATION_POINT)

    define_method "hostgroup_actions_provider" do |method_sym|
      value = instance_variable_get("@hostgroup_actions") || []
      value << method_sym
      instance_variable_set("@hostgroup_actions", value)
    end
  end
end
