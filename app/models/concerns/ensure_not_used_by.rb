# ActiveRecord Callback class
# TODO: it would deserve its own folder
class EnsureNotUsedBy
  attr_reader :klasses
  def initialize(*attribute)
    @klasses = attribute
  end

  def before_destroy(record)
    klasses.each do |klass, klass_name = klass|
      association = record.association(klass.to_sym)
      association_scope = ActiveRecord::Associations::AssociationScope.scope(association)
      next if association_scope.empty?
      authorized_associations = AssociationAuthorizer.authorized_associations(association.klass, klass_name, false).all.pluck(:id)
      association_scope.find_each do |what|
        if authorized_associations.include?(what.id)
          what = what.to_label
          error_message = _("%{record} is used by %{what}")
        else
          what = _(what.class.name)
          error_message = _("%{record} is being used by a hidden %{what} resource")
        end
        record.errors.add :base, error_message % { :record => record, :what => what }
      end
    end
    if record.errors.present?
      Rails.logger.error "You may not destroy #{record.to_label} as it is in use!"
      throw :abort
    end
  end
end
