module TaxonomyCollisionFinder
  extend ActiveSupport::Concern

  module ClassMethods
    def find_without_collision(attribute, value)
      from_local = find_or_initialize_by attribute => value
      from_global = unscoped.find_or_initialize_by attribute => value
      from_local.errors.add(attribute, _("cannot be used, please choose another")) if from_local.new_record? && from_global.persisted?
      from_local
    end
  end
end
