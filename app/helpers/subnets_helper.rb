module SubnetsHelper

  # expand or minimize the subnet when importing
  def minimal? subnets
    subnets.each {|s| return false unless s.errors.empty?}
    subnets.count > 2
  end

  # which options should be shown when importing subnets
  def options subnets
    minimal?(subnets) ? "#{edit} #{ignore}" : ignore
  end

  def ignore
    link_to_function "ignore", "$(this).closest('.imported_subnet').remove()", :class => "label small warning fr"
  end

  def edit
    link_to_function "review", "$(this).parent().parent().children('.subnet_fields').show()", :class => "label small new fr"
  end
end
