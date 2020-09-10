module UINotifications
  # seeds UI notification blueprints that are supported by Foreman.
  class Seed
    attr_reader :attributes

    def initialize(blueprint_attributes)
      @attributes = blueprint_attributes
    end

    def configure
      blueprint = NotificationBlueprint.find_by(name: attributes[:name])
      if blueprint
        blueprint.update!(attributes)
      else
        NotificationBlueprint.create!(attributes)
      end
    end
  end
end
