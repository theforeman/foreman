require 'tsort'
# Add an empty method to nil. Now no need for if x and x.empty?. Just x.empty?
class NilClass
  def empty?
    true
  end
end

class ActiveRecord::Base
  def <=>(other)
    name <=> other.name
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
      attributes.map { |key, value| " #{connection.quote_column_name(key.to_s)} = #{quote_value(value)} " }.join(', ') +
      "WHERE #{self.class.quoted_primary_key} = #{quote_value(id)}",
      "#{self.class.name} Attribute Update"
    )
  end

  # ActiveRecord Callback class
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

  class EnsureNoCycle
    include TSort

    def initialize(base, source, target)
      @source, @target = source, target
      @base = base.map { |record| [record.send(@source), record.send(@target)] }
      @nodes = @base.flatten.uniq
      @graph = Hash.new { |h, k| h[k] = [] }
      @base.each { |s, t| @graph[s] << t }
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
      edges << @record.send(@target) unless edges.include?(@record.send(@target))
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
    where(nil).reorder('').limit(1).pluck(base_class.primary_key).empty?
  end

  def self.per_page
    # Foreman.in_rake? prevents the failure of db:migrate for postgresql
    # don't query settings table if in rake
    return 20 if Foreman.in_rake?
    Setting[:entries_per_page] rescue 20
  end

  def self.audited(*args)
    # do not audit data changes during db migrations
    super
    self.auditing_enabled = false if Foreman.in_setup_db_rake?
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
    match_data = match(/^(\d+(\.\d+)?) ?(([KMGT]i?B?|B|Bytes))?$/i)
    if match_data.present?
      value, _, unit = match_data[1..3]
    else
      raise "Unknown string: #{inspect}!"
    end
    unit ||= :byte # default to bytes if no unit given

    case unit.downcase.to_sym
    when :b, :byte, :bytes then (value.to_f / 1.gigabyte)
    when :tb, :tib, :t, :terabyte then (value.to_f * 1.kilobyte)
    when :gb, :gib, :g, :gigabyte then value.to_f
    when :mb, :mib, :m, :megabyte then (value.to_f / 1.kilobyte)
    when :kb, :kib, :k, :kilobyte then (value.to_f / 1.megabyte)
    else raise "Unknown unit: #{unit.inspect}!"
    end
  end

  def to_utf8
    encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
  end

  def contains_erb?
    # minimum possible ERB is four characters '<%%>'
    return false if size <= 4
    index('<%')
  end

  # TODO Remove me after Rails 6 upgrade: https://github.com/rails/rails/commit/4940cc49ddb361d584d51bc3eb4675ff8ece4a2b
  def truncate_bytes(truncate_at, omission: "…")
    omission ||= ""

    if bytesize <= truncate_at
      dup
    elsif omission.bytesize > truncate_at
      raise ArgumentError, "Omission #{omission.inspect} is #{omission.bytesize}, larger than the truncation length of #{truncate_at} bytes"
    elsif omission.bytesize == truncate_at
      omission.dup
    else
      self.class.new.tap do |cut|
        cut_at = truncate_at - omission.bytesize

        scan(/\X/) do |grapheme|
          if cut.bytesize + grapheme.bytesize <= cut_at
            cut << grapheme
          else
            break
          end
        end

        cut << omission
      end
    end
  end

  def integer?
    to_i.to_s == self
  end
end

class Object
  def contains_erb?
    false
  end

  def integer?
    false
  end
end

class Integer
  def integer?
    true
  end
end

class ActiveModel::Errors
  def are_all_conflicts?
    self[:conflict].count + self[:'interfaces.conflict'].count == count
  end
end
