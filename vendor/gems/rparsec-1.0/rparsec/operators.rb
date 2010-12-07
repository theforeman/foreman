require 'rparsec/parser'

module RParsec

#
# This class helps building lexer and parser for operators.
# The case that one operator (++ for example) contains another operator (+)
# is automatically handled so client code don't have to worry about ambiguity.
# 
class Operators
  #
  # To create an instance of Operators for the given operators.
  # The _block_ parameter, if present, is used to convert the token text to another object
  # when the token is recognized during grammar parsing phase.
  #
  def initialize(ops, &block)
    @lexers = {}
    @parsers = {}
    sorted = Operators.sort(ops)
    lexers = sorted.map do |op|
      symbol = op.to_sym
      result = nil
      if op.length == 1
        result = Parsers.char(op)
      else
        result = Parsers.str(op)
      end
      result = result.token(symbol)
      @lexers[symbol] = result
      @parsers[symbol] = Parsers.token(symbol, &block)
      result
    end
    @lexer = Parsers.sum(*lexers)
  end
  
  #
  # Get the parser for the given operator.
  #
  def parser(op)
    result = @parsers[op.to_sym]
    raise ArgumentError, "parser not found for #{op}" if result.nil?
    result
  end
  
  alias [] parser
  
  #
  # Get the lexer that lexes operators.
  # If an operator is specified, the lexer for that operator is returned.
  #
  def lexer(op=nil)
    return @lexer if op.nil?
    @lexers[op.to_sym]
  end
  
  #
  # Sort an array of operators so that contained operator appears after containers.
  # When no containment exist between two operators, the shorter one takes precedence.
  #
  def self.sort(ops)
    #sort the array by longer-string-first.
    ordered = ops.sort {|x, y|y.length <=> x.length}
    suites = []
    # loop from the longer to shorter string
    ordered.each do |s|
      populate_suites(suites, s)
    end
    # suites are populated with bigger suite first
    to_array suites
  end
  
  private
  
  def self.populate_suites(suites, s)
    # populate the suites so that bigger suite first
    # this way we can use << operator for non-contained strings.
    
    # we need to start from bigger suite. So loop in reverse order
    for suite in suites
      return if populate_suite(suite, s)
    end
    suites << [s]
  end
  
  def self.populate_suite(suite, s)
    # loop from the tail of the suite
    for i in (1..suite.length)
      ind = suite.length - i
      cur = suite[ind]
      if StringUtils.starts_with? cur, s
        suite.insert(ind+1, s) unless cur == s
        return true
      end
    end
    false
  end
  
  def self.to_array suites
    suites.reverse!.flatten!
  end
end

end # module