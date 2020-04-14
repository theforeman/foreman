class CollectionLoader < GraphQL::Batch::Loader
  attr_accessor :model, :association_name, :scope

  def initialize(model, association_name, scope = nil)
    @model = model
    @association_name = association_name
    @scope = scope
    validate
  end

  def load(record)
    raise TypeError, "#{model} loader can't load association for #{record.class}" unless record.is_a?(model)
    if association_loaded?(record) && (!base_scope || base_scope.empty_scope?)
      Promise.resolve(record.public_send(association_name))
    else
      super
    end
  end

  # We want to load the associations on all records, even if they have the same id
  def cache_key(record)
    record.object_id
  end

  def perform(records)
    preloader = preloader_for_association(records)
    records.each { |record| fulfill(record, read_association(preloader, record)) }
  end

  private

  def base_scope
    return authorized_scope unless scope
    scope.call(authorized_scope)
  end

  def validate
    unless reflection
      raise ArgumentError, "No association #{association_name} on #{model.inspect}"
    end
  end

  def preloader_for_association(records)
    ::ActiveRecord::Associations::Preloader.new.preload(records, association_name, base_scope).first
  end

  def read_association(preloader, record)
    preloader.records_by_owner[record] || []
  end

  def authorized_scope
    return unless associated_model.respond_to?(:authorized)

    permission_name = associated_model.find_permission_name(:view)
    associated_model.authorized_as(User.current, permission_name)
  end

  def reflection
    @model.reflect_on_association(association_name)
  end

  def associated_model
    reflection.klass
  end

  def association_loaded?(record)
    record.association(association_name).loaded?
  end
end
