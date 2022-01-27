module Resolvers
  class SettingsResolver < BaseResolver
    type [Types::Setting], null: false

    argument :search, String, 'Search query', required: false

    def resolve(search: nil)
      return [] unless user&.can?(:view_settings)

      scope = Foreman.settings
      scope = scope.search_for(search) if search
      scope.to_a
    end

    private

    def user
      context[:current_user]
    end
  end
end
