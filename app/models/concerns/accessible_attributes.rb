module AccessibleAttributes
  extend ActiveSupport::Concern

  included do
    attr_accessible *((self.attribute_names + ['audit_comment'] +
                      self.reflect_on_all_associations.map { |a| [a.name.to_s, "#{a.name.to_s.singularize}_ids"] }.flatten -
                      ['id', 'created_at', 'updated_at'] -
                      self.protected_attributes.to_a).map(&:to_sym))
  end
end

