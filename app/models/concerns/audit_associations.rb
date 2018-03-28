module AuditAssociations
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def changes_to_save
      if audited_options[:associations].present?
        super.merge(associated_changes)
      else
        super
      end
    end

    private

    def find_association_class(name)
      self.class.reflect_on_association(name).class_name.constantize
    end

    def associated_changes
      associations = Array.wrap(audited_options[:associations])
      associations.each_with_object({}) do |association_name, changes_hash|
        association_ids = "#{association_name.to_s.singularize}_ids"
        if send("#{association_ids}_changed?")
          association_class = find_association_class(association_name)
          change = send("#{association_ids}_change")
          change_ids = change.flatten.uniq

          id_name_map = association_class.where(id: change_ids).inject({}) { |r,p| r.merge(p.id => p.to_label) }

          changes_hash[association_name] = change.each_with_object([]) do |ids, humaized_associations|
            humaized_associations << ids.each_with_object([]) do |id, humanized_ids|
              humanized_ids << id_name_map[id]
            end.join(', ')
          end
        end
      end
    end
  end

  module Auditor
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      include Audited::Auditor::ClassMethods

      def audited(options = {})
        if options[:associations].present?
          configure_dirty_associations(Array(options[:associations]))
        end

        super
      end

      def audit_associations(*associations)
        new_associations = Array(associations)
        if self.respond_to?(:audited_options)
          configure_dirty_associations(new_associations)
          self.audited_options[:associations] = Array(self.audited_options[:associations]) | new_associations
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
end
