module ExposeAssociations
  extend ActiveSupport::Concern

  module ClassMethods
    attr_accessor :exposed_association_groups

    def group_exposed_association(association_name, target_association_name)
      self.exposed_association_groups ||= {}
      self.exposed_association_groups[association_name] ||= []
      self.exposed_association_groups[association_name].push(target_association_name)
      define_exposed_association_groups_getter(association_name)
    end

    def define_exposed_association_groups_getter(association_name)
      return if has_association?(association_name)
      group_class = association_name.to_s.singularize.camelize.constantize
      exposed_association_groups = self.exposed_association_groups[association_name].uniq
      self.send(:define_method, association_name) do
        group_ids = exposed_association_groups.flat_map do |association|
          if self.class.has_association?(association)
            send(association).pluck(:id) rescue [] # in some cases the association doesn't seem to be present, but appears in reflect_on_all_associations
          end
        end
        group_class.where("#{group_class.table_name}.id IN (?)", (group_ids || []))
      end
    end

    def define_association_to_target_model(target_model, through, exposed_model)
      association_name = target_model.to_s.pluralize.underscore.to_sym
      exposed_model = exposed_model.to_s.singularize.camelize.constantize
      exposed_model.class_eval do
        has_many association_name, :through => through.to_s.singularize.to_sym unless has_association?(association_name)
      end
    end

    def expose_association(association_name, target_class = nil, options = {})
      return if target_class.nil?
      self_name = self.to_s
      target_association_name = "#{self_name.pluralize.underscore}_#{association_name.to_s.pluralize.underscore}".to_sym
      self_name = self_name.pluralize.downcase.to_sym
      [target_class, *target_class.descendants].each do |target_model|
        define_association_to_target_model(target_model, self_name, association_name)
        target_model.class_eval do
          include ExposeAssociations
          has_many(target_association_name, options.merge(:through => self_name, :source => association_name))
          group_exposed_association(association_name, target_association_name)
        end
      end
    end
  end
end
