module AuditAssociations
  module AssociationsChanges
    def changes_to_save
      super.merge(associated_changes)
    end

    def audited_attributes
      super.merge(associated_attributes)
    end

    def previous_revision
      revision(:previous)
    end

    protected

    # Prevent associations from being set when looking at revisions since
    # otherwise they will update the original object rather then the revision
    def revision_with(attrs)
      super(attrs.reject { |k, v| k.to_s.ends_with?('_ids') })
    end

    private

    def associated_changes
      audited_options[:associations].each_with_object({}) do |association, changes|
        if public_send("#{association}_changed?")
          changes[association] = public_send("#{association}_change")
        end
      end
    end

    def associated_attributes
      audited_options[:associations].each_with_object({}) do |association, attributes|
        attributes[association] = public_send(association)
      end
    end
  end

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
