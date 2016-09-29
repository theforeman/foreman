# ActiveModel::Dirty does not support associations but it's sometime it'd be useful
# so you could ask like this
#   @user.role_ids_was
#
# This concern can be used exactly for this. Note that it does not detect changes to
# associated object but just change of the collection itself.
#
# Also note one difference to built-in attribute dirty cache for new records. With
# this concern we don't wait on saving the record which results in following behavior
#   @user = User.new
#   @user.role_ids = [8]
#   @user.role_ids = [8, 9]
#   @user.role_ids_was # => [8]
module DirtyAssociations
  extend ActiveSupport::Concern

  module ClassMethods
    # usage:
    #   class Model
    #     dirty_has_many_associations :organizations, :locations
    def dirty_has_many_associations(*args)
      args.each do |association|
        association_ids = association.to_s.singularize + '_ids'

        # result for :organizations
        #   def organization_ids_with_change_detection=(organizations)
        #     organizations ||= []
        #     @organization_ids_changed = organizations.uniq.select(&:present?).map(&:to_i).sort != organization_ids.sort
        #     @organization_ids_was = organization_ids.clone
        #     self.organization_ids_without_change_detection = organizations
        #   end
        define_method "#{association_ids}_with_change_detection=" do |collection|
          collection ||= [] # in API, #{association}_ids is converted to nil if user sent empty array
          instance_variable_set("@#{association_ids}_changed", collection.uniq.select(&:present?).map(&:to_i).sort != self.send(association_ids).sort)
          instance_variable_set("@#{association_ids}_was", self.send(association_ids).clone)
          self.send("#{association_ids}_without_change_detection=", collection)
        end
        alias_method_chain("#{association_ids}=", :change_detection)

        # result for :organizations
        #   def organization_ids_changed?
        #     @organization_ids_changed
        #   end
        define_method "#{association_ids}_changed?" do
          instance_variable_get("@#{association_ids}_changed")
        end

        # result for :organizations
        #   def organization_ids_was
        #     @organization_ids_was ||= organization_ids
        #   end
        define_method "#{association_ids}_was" do
          value = instance_variable_get("@#{association_ids}_was")
          if value.nil?
            instance_variable_set("@#{association_ids}_was", self.send(association_ids))
          else
            value
          end
        end
      end
    end
  end
end
