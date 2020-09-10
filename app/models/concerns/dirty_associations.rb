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

  included do
    after_save :reset_dirty_cache_state
    class_attribute :dirty_associations, default: []
  end

  def reset_dirty_cache_state
    self.class.dirty_associations.each do |assoc|
      send("reset_#{assoc}_dirty_cache_state")
    end
  end

  module ClassMethods
    # usage:
    #   class Model
    #     dirty_has_many_associations :organizations, :locations
    def dirty_has_many_associations(*args)
      self.dirty_associations += args

      extension = Module.new do
        args.each do |association|
          association_ids = association.to_s
          association_ids = association_ids.singularize + '_ids' unless association.to_s.end_with?('_ids')

          define_method "reset_#{association}_dirty_cache_state" do
            instance_variable_set("@#{association_ids}_changed", false)
            instance_variable_set("@#{association_ids}_was", nil)
          end

          # result for :organizations
          #   def organization_ids_with_change_detection=(organizations)
          #     organizations ||= []
          #     @organization_ids_changed = organizations.uniq.select(&:present?).map(&:to_i).sort != organization_ids.sort
          #     @organization_ids_was = organization_ids.clone
          #     self.organization_ids_without_change_detection = organizations
          #   end
          define_method "#{association_ids}=" do |collection|
            # in API, #{association}_ids is converted to nil if user sent empty array
            # in case we got single id, we ensure it's an array
            collection = Array(collection)
            instance_variable_set("@#{association_ids}_changed", collection.uniq.select(&:present?).map(&:to_i).sort != send(association_ids).sort)
            instance_variable_set("@#{association_ids}_was", send(association_ids).clone)
            super(collection)
          end

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
              instance_variable_set("@#{association_ids}_was", send(association_ids))
            else
              value
            end
          end

          define_method "#{association_ids}_change" do
            [send("#{association_ids}_was"), send(association_ids)]
          end
        end
      end
      prepend(extension)
    end
  end
end
