require 'rparsec/misc'

module RParsec

class ParserException < StandardError
  extend DefHelper
  def_readable :index
end
class Failure
  def initialize(ind, input, message=nil)
    @index, @input, @msg = ind, input, message
  end
  
  attr_reader :index, :input
  attr_writer :index
  
  def msg
    return @msg.to_s
  end
  
  Precedence = 100
end

class Expected < Failure
  Precedence = 100
end

end # module