module AuditAssociations
  module AssociationsDefinitions
    def audited(options = {})
      options[:associations] = normalize_associations(options[:associations])
      if options[:associations].present?
        configure_dirty_associations(options[:associations])
      end

      super
    end

    def audit_associations(*associations)
      new_associations = normalize_associations(associations)
      if respond_to?(:audited_options)
        configure_dirty_associations(new_associations)
        audited_options[:associations] = audited_options[:associations] | new_associations
      else
        logger.warn "ignoring associations #{new_associations.join(', ')} audit definition for #{self}, the resource is not audited"
      end
    end

    def normalize_associations(associations)
      Array(associations).map do |association|
        "#{association.to_s.singularize}_ids"
      end
    end

    def configure_dirty_associations(associations)
      include DirtyAssociations unless included_modules.include?(DirtyAssociations)
      dirty_has_many_associations(*associations)
    end
  end
end
