module SubnetsHelper

  # expand or minimize the subnet when importing
  def minimal? subnets
    subnets.each {|s| return false unless s.errors.empty?}
    subnets.size > 2
  end

end
