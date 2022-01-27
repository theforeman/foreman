module Resolvers
  class SettingResolver < BaseResolver
    type Types::Setting, null: false

    argument :id, String, 'Global ID for Record', required: true

    def resolve(id:)
      name = Foreman::GlobalId.decode(id).last
      if ::User.current.can?(:view_settings)
        Foreman.settings.find(name)
      end
    end
  end
end
