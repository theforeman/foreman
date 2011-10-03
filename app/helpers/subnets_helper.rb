module SubnetsHelper

  # expand or minimize the subnet when importing
  def minimal? subnets
    subnets.each {|s| return false unless s.errors.empty?}
    subnets.count > 1
  end

  # which options should be shown when importing subnets
  def options subnets
    minimal?(subnets) ? "#{edit} or #{ignore}" : ignore
  end

  def ignore
    link_to_function "ignore", "$(this).closest('.imported_subnet').remove()"
  end

  def edit
    link_to_function "review", "$(this).parent().parent().children('.subnet_fields').show()"
  end
end
