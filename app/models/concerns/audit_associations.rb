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

    def associated_changes
      associations = Array.wrap(audited_options[:associations])
      associations.inject({}) do |changes_hash, association_name|
        association_ids = "#{association_name.to_s.singularize}_ids"

        if send("#{association_ids}_changed?")
          association_class = self.class.reflect_on_association(association_name).class_name.constantize
          change = send("#{association_ids}_change")
          change_ids = change.flatten.uniq

          id_name_map = association_class.where(id: change_ids).inject({}) { |r,p| r.merge(p.id => p.to_label) }

          changes_hash[association_name] = change.inject([]) do |humaized_associations, ids|
            humaized_associations << ids.inject([]) do |humanized_ids, id|
              humanized_ids << id_name_map[id]
              humanized_ids
            end.join(', ')
            humaized_associations
          end
        end

        changes_hash
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
          include DirtyAssociations

          dirty_has_many_associations(*(Array(options[:associations])))
        end

        super
      end
    end
  end
end
