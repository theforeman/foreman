class SmartProxyReference
  attr_reader :join_relation, :columns

  def initialize(hash)
    @join_relation = hash.keys.first
    @columns = hash.values.first
  end

  def columns_to_s
    @columns.map(&:to_s)
  end

  def join?
    @join_relation != :self
  end

  def merge(other)
    @columns = @columns.concat(other.columns).uniq
  end

  def host_reflection
    Host::Managed.reflections[@join_relation.to_s]
  end

  def valid?
    !!host_reflection
  end

  def table_name
    valid? ? host_reflection.table_name : nil
  end

  def map_column_names(count)
    return [] unless join?
    @columns.map do |col_name|
      alias_name = (count > 0) ? "#{@join_relation.to_s.pluralize}_hosts" : table_name
      "#{alias_name}.#{col_name}"
    end
  end
end
