require 'rparsec/misc'

module RParsec

#
# Represents a token during lexical analysis.
#
class Token
  extend DefHelper
  
  def_ctor :kind, :text, :index
  
  #
  # The type of the token
  #
  attr_reader :kind
  
  #
  # The text of the matched range
  #
  attr_reader :text
  
  #
  # The starting index of the matched range
  #
  attr_reader :index
  
  #
  # The length of the token.
  #
  def length
    @text.length
  end
  
  #
  # String representation of the token.
  # 
  def to_s
    "#{@kind}: #{@text}"
  end
end

end # module