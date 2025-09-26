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
    return [] if records.empty?

    preloader = preloader_for_association(records)
    return [] if preloader.nil?

    reader_method = association_reader(preloader, base_scope, records)
    records.each { |record| fulfill(record, reader_method.call(preloader, record)) }
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
    ::ActiveRecord::Associations::Preloader.new(records: records, associations: association_name, scope: base_scope).call.first
  end

  def association_reader(preloader, scope, records)
    return method(:read_association) if base_scope.nil?

    all_associated_ids = records.flat_map do |record|
      read_association(preloader, record).map(&association_pkey)
    end.uniq

    # Apply scope to get filtered IDs
    filtered_ids = base_scope.where(id: all_associated_ids).pluck(association_pkey).to_set

    method(:read_filtered_association).curry.call(filtered_ids)
  end

  def read_association(preloader, record)
    preloader.records_by_owner[record] || []
  end

  def read_filtered_association(filtered_ids, preloader, record)
    read_association(preloader, record)
      .select { |r| filtered_ids.include?(r.public_send(association_pkey)) }
  end

  def authorized_scope
    return unless associated_model.respond_to?(:authorized)

    model = reflected_class
    permission_name = model.find_permission_name(:view)

    scope = model
    scope = scope.public_send("my_#{model.name.downcase.pluralize}") if model < Taxonomy
    scope.authorized_as(User.current, permission_name)
  end

  def reflection
    @model.reflect_on_association(association_name)
  end

  def association_pkey
    @association_pkey ||= reflection.active_record_primary_key.to_sym
  end

  def associated_model
    reflection.klass
  end

  def association_loaded?(record)
    record.association(association_name).loaded?
  end

  def reflected_class
    return associated_model unless reflection.klass <= Taxonomy

    case reflection.name
    when :locations
      Location
    when :organizations
      Organization
    end
  end
end
