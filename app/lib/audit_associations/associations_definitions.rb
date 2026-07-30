module AuditAssociations
  module AssociationsDefinitions
    def audited(options = {})
      options = options.dup
      options[:associations] = normalize_associations(options[:associations])
      if options[:associations].present?
        configure_dirty_associations(options[:associations])
      end

      if audited_already? && association_only_audited_update?(options)
        audited_options[:associations] = Array(audited_options[:associations]) | options[:associations]
        return
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

    private

    def audited_already?
      included_modules.include?(Audited::Auditor::AuditedInstanceMethods)
    end

    # True when the caller only supplied :associations (the pattern used by plugins
    # to extend association auditing). Explicit :except/:only/:on/etc. still replace.
    def association_only_audited_update?(options)
      options[:associations].present? &&
        (options.keys.map(&:to_sym) - [:associations]).empty?
    end
  end
end
