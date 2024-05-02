module AuditAssociations
  module AssociationsChanges
    def changes_to_save
      super.merge(associated_changes)
    end

    def audited_attributes
      super.merge(associated_attributes)
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
end
