require 'ostruct'

class SettingValueSelection
  attr_reader :kind, :collection

  def initialize(collection, options)
    if collection.is_a?(Array)
      @kind = :array
      @collection = editable_select_optgroup(collection, :include_blank => options[:include_blank])
      return self
    end

    if collection.is_a?(Hash)
      @kind = :hash
      @collection = collection
      return self
    end

    raise "Expected collection to be Hash or Array, found: #{collection}"
  end

  private

  def editable_select_optgroup(groups, options = {})
    select = groups.reduce([]) do |memo, group|
      klass = group[:class].classify.constantize
      scope = group[:scope]
      children = klass.send(scope).map { |obj| OpenStruct.new({ :label => obj.send(group[:text_method]), :value => obj.send(group[:value_method]) }) }
      memo.tap { |acc| acc.push(OpenStruct.new(:group_label => group[:name], :children => children)) }
    end
    select.unshift(OpenStruct.new({ :value => nil, :label => options[:include_blank] })) if options[:include_blank].present?
    select
  end
end
