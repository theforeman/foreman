module TemplateTax
  extend ActiveSupport::Concern

  module ClassMethods
    def taxonomy_exportable
      {
        :organizations => method(:assigned_organization_titles),
        :locations => method(:assigned_location_titles),
      }
    end

    def assigned_organization_titles(template, user = User.current)
      template.organizations.select { |org| user.my_organizations.include?(org) }.map(&:title)
    end

    def assigned_location_titles(template, user = User.current)
      template.locations.select { |loc| user.my_locations.include?(loc) }.map(&:title)
    end
  end
end
