module AuditAssociations
  module AssociationsChanges
    def changes_to_save
      super.merge(associated_changes)
    end

    def audited_attributes
      super.merge(associated_attributes)
    end

    private

    def find_association_class(name)
      self.class.reflect_on_association(name).class_name.constantize
    end

    def associated_changes
      audited_options[:associations].each_with_object({}) do |association, changes|
        association_ids = "#{association.to_s.singularize}_ids"
        if public_send("#{association_ids}_changed?")
          change = public_send("#{association_ids}_change")

          changes[association] = change.map do |ids|
            associated_names(association, ids)
          end
        end
      end
    end

    def associated_attributes
      audited_options[:associations].each_with_object({}) do |association, attributes|
        ids = public_send("#{association.to_s.singularize}_ids")
        attributes[association.to_s] = associated_names(association, ids)
      end
    end

    def associated_names(association, ids)
      find_association_class(association).where(id: ids).map(&:to_label).sort.join(', ')
    end
  end

  module AssociationsDefinitions
    def audited(options = {})
      options[:associations] = Array(options[:associations])
      if options[:associations].present?
        configure_dirty_associations(options[:associations])
      end

      super
    end

    def audit_associations(*associations)
      new_associations = Array(associations)
      if self.respond_to?(:audited_options)
        configure_dirty_associations(new_associations)
        self.audited_options[:associations] = self.audited_options[:associations] | new_associations
      else
        logger.warn "ignoring associations #{new_associations.join(', ')} audit definition for #{self}, the resource is not audited"
      end
    end

    def configure_dirty_associations(associations)
      include DirtyAssociations unless included_modules.include?(DirtyAssociations)
      dirty_has_many_associations(*associations)
    end
  end
end
