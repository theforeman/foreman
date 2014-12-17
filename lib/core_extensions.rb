require 'tsort'
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
    def initialize(*attribute)
      @klasses = attribute
      @logger  = Rails.logger
    end

    def before_destroy(record)
      klasses.each do |klass|
        record.send(klass.to_sym).each do |what|
          what = what.to_label unless what.is_a? String
          record.errors.add :base, _("%{record} is used by %{what}") % { :record => record, :what => what }
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

  class EnsureNoCycle
    include TSort

    def initialize(base, source, target)
      @source, @target = source, target
      @base  = base.map { |record| [record.send(@source), record.send(@target)] }
      @nodes = @base.flatten.uniq
      @graph = Hash.new { |h, k| h[k] = [] }
      @base.each { |s, t| @graph[s]<< t }
    end

    def tsort_each_node(&block)
      @nodes.each(&block)
    end

    def tsort_each_child(node, &block)
      @graph[node].each(&block)
    end

    def ensure(record)
      @record = record
      add_new_edges
      detect_cycle
    end

    private

    def add_new_edges
      edges = @graph[@record.send(@source) || 0]
      edges<< @record.send(@target) unless edges.include?(@record.send(@target))
    end

    def detect_cycle
      if strongly_connected_components.any? { |component| component.size > 1 }
        @record.errors.add :base, _("Adding would cause a cycle!")
        raise ::Foreman::CyclicGraphException, @record
      else
        true
      end
    end
  end

  def id_and_type
    "#{id}-#{self.class.table_name.humanize}"
  end
  alias_attribute :to_label, :name_method
  alias_attribute :to_s, :to_label

  def self.unconfigured?
    all.reorder('').limit(1).pluck(self.base_class.primary_key).empty?
  end

  def self.per_page
    # Foreman.in_rake? prevents the failure of db:migrate for postgresql
    # don't query settings table if in rake
    return 20 if Foreman.in_rake?
    Setting.entries_per_page rescue 20
  end
end

module ExemptedFromLogging
  def process(request, *args)
    logger.silence { super }
  end
end

class String
  def to_translation
    _(self)
  end

  def to_gb
    begin
      value, _, unit=self.match(/(\d+(\.\d+)?) ?(([KMGT]B?|B))$/i)[1..3]
      case unit.to_sym
      when nil, :B, :byte          then (value.to_f / Foreman::SIZE[:giga])
      when :TB, :T, :terabyte      then (value.to_f * Foreman::SIZE[:kilo])
      when :GB, :G, :gigabyte      then value.to_f
      when :MB, :M, :megabyte      then (value.to_f / Foreman::SIZE[:kilo])
      when :KB, :K, :kilobyte, :kB then (value.to_f / Foreman::SIZE[:mega])
      else raise "Unknown unit: #{unit.inspect}!"
      end
    rescue
      raise "Unknown string: #{self.inspect}!"
    end
  end
end

class ActiveModel::Errors
  def are_all_conflicts?
    self[:conflict].count + self[:'interfaces.conflict'].count == self.count
  end
end
