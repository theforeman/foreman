class SettingValueSelection
  attr_reader :collection

  def initialize(collection, options)
    raise "Expected collection to be Hash or Array, found: #{collection}" unless collection.is_a?(Array) || collection.is_a?(Hash)

    if collection.is_a?(Array)
      @collection = editable_select_optgroup(collection, :include_blank => options[:include_blank])
    end

    if collection.is_a?(Hash)
      @collection = collection
    end
  end

  private

  # creates a data set for editable select-optgroup. each element in the 'groups' array is a hash represents a group with its children.
  # e.g - {:name => _("Users"), :class => 'user', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'login'}
  # :name -> group's name, :scope -> scoped method (e.g 'all' or another predefined scope),
  # :value_method -> value in params, and text_method -> the shown text in the select element.

  def editable_select_optgroup(groups, options = {})
    select = groups.reduce([]) do |memo, group|
      klass = group[:class].classify.constantize
      scope = group[:scope]
      children = klass.send(scope).map { |obj| { :label => obj.send(group[:text_method]), :value => obj.send(group[:value_method]) } }
      memo.tap { |acc| acc.push(:group_label => group[:name], :children => children) }
    end
    select.unshift(:value => nil, :label => options[:include_blank]) if options[:include_blank].present?
    select
  end
end
