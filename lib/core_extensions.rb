ActiveRecord::Associations::HasManyThroughAssociation.class_eval do
  def delete_records(records)
    klass = @reflection.through_reflection.klass
    records.each do |associate|
      klass.destroy_all(construct_join_attributes(associate))
    end
  end
end

# Add an empty method to nil. Now no need for if x and x.empty?. Just x.empty?
class NilClass
  def empty?
    true
  end
end

class ActiveRecord::Base
  def <=>(other)
    self.name <=> other.name
  end

  def update_single_attribute(attribute, value)
    connection.update(
      "UPDATE #{self.class.quoted_table_name} SET " +
      "#{connection.quote_column_name(attribute.to_s)} = #{quote_value(value)} " +
      "WHERE #{self.class.quoted_primary_key} = #{quote_value(id)}",
      "#{self.class.name} Attribute Update"
    )
  end

  def update_multiple_attribute(attributes)
    connection.update(
      "UPDATE #{self.class.quoted_table_name} SET " +
      attributes.map{|key, value| " #{connection.quote_column_name(key.to_s)} = #{quote_value(value)} " }.join(', ') +
      "WHERE #{self.class.quoted_primary_key} = #{quote_value(id)}",
      "#{self.class.name} Attribute Update"
    )
  end

  # ActiveRecord Callback class
  class EnsureNotUsedBy
    attr_reader :klasses, :logger
    def initialize *attribute
      @klasses = attribute
      @logger  = Rails.logger
    end

    def before_destroy(record)
      klasses.each do |klass|
        record.send(klass.to_sym).each do |what|
          record.errors.add :base, "#{record} is used by #{what}"
        end
      end
      if record.errors.empty?
        true
      else
        logger.error "You may not destroy #{record.to_label} as it is in use!"
        false
      end
    end
  end

  def id_and_type
    "#{id}-#{self.class.table_name.humanize}"
  end
  alias_attribute :to_label, :name
  alias_attribute :to_s, :to_label

  def self.unconfigured?
    scoped.reorder('').limit(1).pluck(self.base_class.primary_key).nil?
  end

  def self.per_page
    # defined?(Rake) prevents the failure of db:migrate for postgresql
    # don't query settings table if in rake
    return 20 if defined?(Rake)
    Setting.entries_per_page rescue 20
  end
end

module ActiveRecord
  class Base
    class << self
      delegate :pluck, :to=> :scoped
    end
  end

  class CollectionProxy
    delegate :pluck, :to => :scoped
  end

  # = Active Record Relation
  class Relation
    # Returns <tt>Array</tt> with values of the specified column name
    # The values has same data type as column.
    #
    # Examples:
    #
    # Person.pluck(:id) # SELECT people.id FROM people
    # Person.uniq.pluck(:role) # SELECT DISTINCT role FROM people
    # Person.where(:confirmed => true).limit(5).pluck(:id)
    #
    def pluck(column_name)
      if column_name.is_a?(Symbol) && column_names.include?(column_name.to_s)
        column_name = "#{table_name}.#{column_name}"
      end
      scope = self.select(column_name)
      self.connection.select_values(scope.to_sql).map! do |value|
        type_cast_using_column(value, column_for(column_name))
      end
    end
  end
end

module ExemptedFromLogging
  def process(request, *args)
    logger.silence { super }
  end
end

class String
  def to_gb
    begin
      value,f,unit=self.match(/(\d+(\.\d+)?) ?(([KMGT]B?|B))$/i)[1..3]
      case unit.to_sym
      when nil, :B, :byte          then (value.to_f / (4**10))
      when :TB, :T, :terabyte      then (value.to_f * (2**10))
      when :GB, :G, :gigabyte      then value.to_f
      when :MB, :M, :megabyte      then (value.to_f / (2**10))
      when :KB, :K, :kilobyte, :kB then (value.to_f / (3**10))
      else raise "Unknown unit: #{unit.inspect}!"
      end
    rescue
      raise "Unknown string: #{self.inspect}!"
    end
  end
end

class ActiveModel::Errors
  def are_all_conflicts?
    self[:conflict].count == self.count
  end
end
