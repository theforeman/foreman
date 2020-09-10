class RecordLoader < GraphQL::Batch::Loader
  def initialize(model)
    @model = model
  end

  def perform(ids)
    authorized_scope.where(id: ids).each { |record| fulfill(record.id, record) }
    ids.each { |id| fulfill(id, nil) unless fulfilled?(id) }
  end

  def load_by_global_id(global_id)
    id = Foreman::GlobalId.decode(global_id).last.to_i
    load(id)
  end

  private

  def authorized_scope
    return @model unless @model.respond_to?(:authorized)

    permission_name = @model.find_permission_name(:view)
    @model.authorized_as(User.current, permission_name)
  end
end
