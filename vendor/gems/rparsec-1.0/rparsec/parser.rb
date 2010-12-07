%w{
monad misc error context locator token functors parser_monad
}.each {|lib| require "rparsec/#{lib}"}
require 'strscan'

module RParsec
  
#
# Represents a parser that parses a certain grammar rule.
#
class Parser
  include Functors
  include Monad
  extend Signature
  extend DefHelper
  MyMonad = ParserMonad.new
  attr_accessor :name
  
  private
  
  def initialize
    initMonad(MyMonad, self)
  end
  
  def self.init(*vars)
    parser_checker = {}
    vars.each_with_index do |var, i|
      name = var.to_s
      parser_checker[i] = var if name.include?('parser') && !name.include?('parsers')
    end
    define_method(:initialize) do |*params|
      super()
      vars.each_with_index do |var, i|
        param = params[i]
        if parser_checker.include? i
          TypeChecker.check_arg_type Parser, param, self, i
        end
        instance_variable_set("@"+var.to_s, param)
      end
    end
  end
  
  def _display_current_input(input, code, index)
    return 'EOF' if input.nil?
    c = input
    case c when Fixnum then "'"<<c<<"'" when Token then c.text else c.to_s end
  end
  
  def _add_encountered_error(msg, encountered)
    result = msg.dup
    result << ', ' unless msg.strip.length == 0 || msg =~ /.*(\.|,)\s*$/
    "#{result}#{encountered}"
  end
  
  def _add_location_to_error(locator, ctxt, msg, code)
    line, col = locator.locate(ctxt.error.index)
    msg << " at line #{line}, col #{col}."
  end
  
  public
  
  #
  # parses a string.
  #
  def parse(src)
    ctxt = ParseContext.new(src)
    return ctxt.result if _parse ctxt
    ctxt.prepare_error
    locator = CodeLocator.new(src)
    raise ParserException.new(ctxt.error.index), 
      _add_location_to_error(locator, ctxt, 
        _add_encountered_error(ctxt.to_msg,
           _display_current_input(ctxt.error.input, src, ctxt.index)), src)
  end
  
  #
  # Set name for the parser.
  # self is returned.
  #
  def setName(nm)
    @name = nm
    self
  end
  
  #
  # a.map{|x|x+1} will first execute parser a, when it succeeds,
  # the associated block is executed to transform the result to a new value
  # (increment it in this case).
  #
  def map(&block)
    return self unless block
    MapParser.new(self, block)
  end
  
  #
  # _self_ is first executed, the parser result is then passed as parameter to the associated block,
  # which evaluates to another Parser object at runtime. This new Parser object is then executed
  # to get the final parser result.
  #
  # Different from _bind_, parser result of _self_ will be expanded first if it is an array.
  #
  def bindn(&block)
    return self unless block
    BoundnParser.new(self, block)
  end
  
  #
  # a.mapn{|x,y|x+y} will first execute parser a, when it succeeds,
  # the array result (if any) is expanded and passed as parameters
  # to the associated block. The result of the block is then used
  # as the parsing result.
  #
  def mapn(&block)
    return self unless block
    MapnParser.new(self, block)
  end
  
  #
  # Create a new parser that's atomic.,
  # meaning that when it fails, input consumption is undone.
  # 
  def atomize
    AtomParser.new(self).setName(@name)
  end
  
  #
  # Create a new parser that looks at inputs whthout consuming them.
  # 
  def peek
    PeekParser.new(self).setName(@name)
  end
  
  #
  # To create a new parser that succeed only if self fails.
  # 
  def not(msg="#{self} unexpected")
    NotParser.new(self, msg)
  end
  
  #
  # To create a parser that does "look ahead" for n inputs.
  # 
  def lookahead n
    self
  end
  
  #
  # To create a parser that fails with a given error message.
  # 
  def expect msg
    ExpectParser.new(self, msg)
  end
  
  #
  # a.followed b will sequentially run a and b;
  # result of a is preserved as the ultimate return value.
  # 
  def followed(other)
    FollowedParser.new(self, other)
  end
  def_sig :followed, Parser
  
  #
  # To create a parser that repeats self for a minimum _min_ times,
  # and maximally _max_ times.
  # Only the return value of the last execution is preserved.
  # 
  def repeat_(min, max=min)
    return Parsers.failure("min=#{min}, max=#{max}") if min > max
    if(min==max)
      return Parsers.one if max <= 0
      return self if max == 1
      Repeat_Parser.new(self, max)
    else
      Some_Parser.new(self, min, max)
    end
  end
  
  #
  # To create a parser that repeats self for a minimum _min_ times,
  # and maximally _max_ times.
  # All return values are collected in an array.
  # 
  def repeat(min, max=min)
    return Parsers.failure("min=#{min}, max=#{max}") if min > max
    if(min==max)
      RepeatParser.new(self, max)
    else
      SomeParser.new(self, min, max)
    end
  end
  
  # 
  # To create a parser that repeats self for at least _least_ times.
  # parser.many_ is equivalent to bnf notation "parser*".
  # Only the return value of the last execution is preserved.
  # 
  def many_(least=0)
    Many_Parser.new(self, least)
  end
  
  # 
  # To create a parser that repeats self for at least _least_ times.
  # All return values are collected in an array.
  # 
  def many(least=0)
    ManyParser.new(self, least)
  end
  
  # 
  # To create a parser that repeats self for at most _max_ times.
  # Only the return value of the last execution is preserved.
  # 
  def some_(max)
    repeat_(0, max)
  end
  
  # 
  # To create a parser that repeats self for at most _max_ times.
  # All return values are collected in an array.
  # 
  def some(max)
    repeat(0, max)
  end
  
  #
  # To create a parser that repeats self for unlimited times,
  # with the pattern recognized by _delim_ as separator that separates each occurrence.
  # self has to match for at least once.
  # Return values of self are collected in an array.
  #
  def separated1 delim
    rest = delim >> self
    self.bind do |v0|
      result = [v0]
      (rest.map {|v| result << v}).many_ >> value(result)
    end
  end
  
  #
  # To create a parser that repeats self for unlimited times,
  # with the pattern recognized by _delim_ as separator that separates each occurrence.
  # Return values of self are collected in an array.
  #
  def separated delim
    separated1(delim).plus value([])
  end
  
  #
  # To create a parser that repeats self for unlimited times,
  # with the pattern recognized by _delim_ as separator that separates each occurrence
  # and also possibly ends the pattern.
  # self has to match for at least once.
  # Return values of self are collected in an array.
  #
  def delimited1 delim
    rest = delim >> (self.plus Parsers.throwp(:__end_delimiter__))
    self.bind do |v0|
      result = [v0]
      (rest.map {|v| result << v}).many_.catchp(:__end_delimiter__) >> value(result)
    end
  end
  
  #
  # To create a parser that repeats self for unlimited times,
  # with the pattern recognized by _delim_ as separator that separates each occurrence
  # and also possibly ends the pattern.
  # Return values of self are collected in an array.
  #
  def delimited delim
    delimited1(delim).plus value([])
  end
  
  #
  # String representation
  #
  def to_s
    return name unless name.nil?
    self.class.to_s
  end
  
  # 
  # a | b will run b when a fails.
  # b is auto-boxed to Parser when it is not of type Parser.
  #
  def | other
    AltParser.new([self, autobox_parser(other)])
  end
  
  #
  # a.optional(default) is equivalent to a.plus(value(default))
  #
  def optional(default=nil)
    self.plus(value(default))
  end
  
  #
  # a.catchp(:somesymbol) will catch the :somesymbol thrown by a.
  #
  def catchp(symbol)
    CatchParser.new(symbol, self)
  end
  
  #
  # a.fragment will return the string matched by a.
  #
  def fragment
    FragmentParser.new(self)
  end
  
  #
  # a.nested b will feed the token array returned by parser a to parser b
  # for a nested parsing.
  #
  def nested(parser)
    NestedParser.new(self, parser)
  end
  
  #
  # a.lexeme(delim) will parse _a_ for 0 or more times and ignore all
  # patterns recognized by _delim_.
  # Values returned by _a_ are collected in an array.
  #
  def lexeme(delim = Parsers.whitespaces)
    delim = delim.many_
    delim >> self.delimited(delim)
  end
  
  #
  # For prefix unary operator.
  # a.prefix op will run parser _op_ for 0 or more times and eventually run parser _a_
  # for one time.
  # _op_ should return a Proc that accepts one parameter.
  # Proc objects returned by _op_ is then fed with the value returned by _a_
  # from right to left.
  # The final result is returned as return value.
  #
  def prefix(op)
    Parsers.sequence(op.many, self) do |funcs, v|
      funcs.reverse_each {|f|v=f.call(v)}
      v
    end
  end
  
  #
  # For postfix unary operator.
  # a.postfix op will run parser _a_ for once and then _op_ for 0 or more times.
  # _op_ should return a Proc that accepts one parameter.
  # Proc objects returned by _op_ is then fed with the value returned by _a_
  # from left to right.
  # The final result is returned as return value.
  #
  def postfix(op)
    Parsers.sequence(self, op.many) do |v, funcs|
      funcs.each{|f|v=f.call(v)}
      v
    end
  end
  
  #
  # For non-associative infix binary operator.
  # _op_ has to return a Proc that takes two parameters, who
  # are returned by the _self_ parser as operands.
  #
  def infixn(op)
    bind do |v1|
      bin = Parsers.sequence(op, self) do |f, v2|
        f.call(v1,v2)
      end
      bin | value(v1)
    end
  end
  
  #
  # For left-associative infix binary operator.
  # _op_ has to return a Proc that takes two parameters, who
  # are returned by the _self_ parser as operands.
  #
  def infixl(op)
    Parsers.sequence(self, _infix_rest(op, self).many) do |v, rests|
      rests.each do |r|
        f, v1 = *r
        v = f.call(v,v1)
      end
      v
    end
  end
  
  #
  # For right-associative infix binary operator.
  # _op_ has to return a Proc that takes two parameters, who
  # are returned by the _self_ parser as operands.
  #
  def infixr(op)
    Parsers.sequence(self, _infix_rest(op, self).many) do |v, rests|
      if rests.empty?
        v
      else
        f, seed = *rests.last
        for i in (0...rests.length-1)
          cur = rests.length-2-i
          f1, v1 = *rests[cur]
          seed = f.call(v1, seed)
          f = f1
        end
        f.call(v, seed)
      end
    end
  end
  
  #
  # a.token(:word_token) will return a Token object when _a_ succeeds.
  # The matched string (or the string returned by _a_, if any) is
  # encapsulated in the token, together with the :word_token symbol and
  # the starting index of the match.
  #
  def token(kind)
    TokenParser.new(kind, self)
  end
  
  #
  # a.seq b will sequentially run a then b.
  # The result of b is preserved as return value.
  # If a block is associated, values returned by _a_ and _b_
  # are passed into the block and the return value of
  # the block is used as the final result of the parser.
  #
  def seq(other, &block)
    # TypeChecker.check_arg_type Parser, other, :seq
    Parsers.sequence(self, other, &block)
  end
  def_sig :seq, Parser
  
  #
  # Similar to _seq_. _other_ is auto-boxed if it is not of type Parser.
  #
  def >> (other)
    seq(autobox_parser(other))
  end
  
  private
  
  def autobox_parser(val)
    return Parsers.value(val) unless val.kind_of? Parser
    val
  end
  
  def _infix_rest(operator, operand)
    Parsers.sequence(operator, operand, &Idn)
  end
  
  public
  
  alias ~ not
  alias << followed
  alias * repeat_
  
  def_sig :plus, Parser
  
  private
  
  def _parse(ctxt)
    false
  end
end
#
# This module provides all out-of-box parser implementations.
#
module Parsers
  extend Signature
  
  #
  # A parser that always fails with the given error message.
  #
  def failure msg
    FailureParser.new(msg)
  end
  
  #
  # A parser that always succeeds with the given return value.
  #
  def value v
    ValueParser.new(v)
  end
  
  #
  # A parser that calls alternative parsers until one succeed,
  # or any failure with input consumption beyond the current look-ahead.
  #
  def sum(*alts)
    # TypeChecker.check_vararg_type Parser, alts, :sum
    PlusParser.new(alts)
  end
  def_sig :sum, [Parser]
  
  #
  # A parser that calls alternative parsers until one succeeds.
  #
  def alt(*alts)
    AltParser.new(alts)
  end
  def_sig :alt, [Parser]
  
  #
  # A parser that succeeds when the given predicate returns true
  # (with the current input as the parameter).
  # _expected_ is the error message when _pred_ returns false.
  #
  def satisfies(expected, &pred)
    SatisfiesParser.new(pred, expected)
  end
  
  #
  # A parser that succeeds when the the current input is equal to the given value.
  # _expected_ is the error message when _pred_ returns false.
  #
  def is(v, expected="#{v} expected")
    satisfies(expected) {|c|c==v}
  end
  
  #
  # A parser that succeeds when the the current input is not equal to the given value.
  # _expected_ is the error message when _pred_ returns false.
  #
  def isnt(v, expected="#{v} unexpected")
    satisfies(expected) {|c|c!=v}
  end
  
  #
  # A parser that succeeds when the the current input is among the given values.
  #
  def among(*vals)
    expected="one of [#{vals.join(', ')}] expected"
    vals = as_list vals
    satisfies(expected) {|c|vals.include? c}
  end
  
  #
  # A parser that succeeds when the the current input is not among the given values.
  #
  def not_among(*vals)
    expected = "one of [#{vals.join(', ')}] unexpected"
    vals = as_list vals
    satisfies(expected) {|c|!vals.include? c}
  end
  
  #
  # A parser that succeeds when the the current input is the given character.
  #
  def char(c)
    if c.kind_of? Fixnum
      nm = c.chr
      is(c, "'#{nm}' expected").setName(nm)
    else
      is(c[0], "'#{c}' expected").setName(c)
    end
  end
  
  #
  # A parser that succeeds when the the current input is not the given character.
  #
  def not_char(c)
    if c.kind_of? Fixnum
      nm = c.chr
      isnt(c, "'#{nm}' unexpected").setName("~#{nm}")
    else
      isnt(c[0], "'#{c}' unexpected").setName("~#{c}")
    end
  end
  
  #
  # A parser that succeeds when there's no input available.
  #
  def eof(expected="EOF expected")
    EofParser.new(expected).setName('EOF')
  end
  
  #
  # A parser that tries to match the current inputs one by one
  # with the given values.
  # It succeeds only when all given values are matched, in which case all the
  # matched inputs are consumed.
  #
  def are(vals, expected="#{vals} expected")
    AreParser.new(vals, expected)
  end
  
  #
  # A parser that makes sure that the given values don't match
  # the current inputs. One input is consumed if it succeeds.
  #
  def arent(vals, expected="#{vals} unexpected")
    are(vals, '').not(expected) >> any
  end
  
  #
  # A parser that matches the given string.
  #
  def string(str, msg = "\"#{str}\" expected")
    are(str, msg).setName(str)
  end
  
  #
  # A parser that makes sure that the current input doesn't match a string.
  # One character is consumed if it succeeds.
  #
  def not_string(str, msg="\"#{str}\" unexpected")
    string(str).not(msg) >> any
  end
  
  alias str string
  
  #
  # A parser that sequentially run the given parsers.
  # The result of the last parser is used as return value.
  # If a block is given, the results of the parsers are passed
  # into the block as parameters, and the block return value
  # is used as result instead.
  #
  def sequence(*parsers, &proc)
    # TypeChecker.check_vararg_type Parser, parsers, :sequence
    SequenceParser.new(parsers, proc)
  end
  def_sig :sequence, [Parser]
  
  #
  # A parser that returns the current input index (starting from 0).
  #
  def get_index
    GetIndexParser.new.setName('get_index')
  end
  
  #
  # A parser that moves the current input pointer to a certain index.
  #
  def set_index ind
    SetIndexParser.new(ind).setName('set_index')
  end
  
  #
  # A parser that tries all given alternative parsers
  # and picks the one with the longest match.
  #
  def longest(*parsers)
    # TypeChecker.check_vararg_type Parser, parsers, :longest
    BestParser.new(parsers, true)
  end
  def_sig :longest, [Parser]
  
  #
  # A parser that tries all given alternative parsers
  # and picks the one with the shortest match.
  #
  def shortest(*parsers)
    # TypeChecker.check_vararg_type Parser, parsers, :shortest
    BestParser.new(parsers, false)
  end
  def_sig :shortest, [Parser]
  
  alias shorter shortest
  alias longer longest
  
  #
  # A parser that consumes one input.
  #
  def any
    AnyParser.new
  end
  
  #
  # A parser that always fails.
  #
  def zero
    ZeroParser.new
  end
  
  #
  # A parser that always succeeds.
  #
  def one
    OneParser.new
  end
  
  #
  # A parser that succeeds if the current input is within a certain range.
  #
  def range(from, to, msg="#{as_char from}..#{as_char to} expected")
    from, to = as_num(from), as_num(to)
    satisfies(msg) {|c| c <= to && c >= from}
  end
  
  #
  # A parser that throws a symbol.
  #
  def throwp(symbol)
    ThrowParser.new(symbol)
  end
  
  #
  # A parser that succeeds if the current inputs match
  # the given regular expression.
  # The matched string is consumed and returned as result.
  #
  def regexp(ptn, expected="/#{ptn.to_s}/ expected")
    RegexpParser.new(as_regexp(ptn), expected).setName(expected)
  end
  
  #
  # A parser that parses a word
  # (starting with alpha or underscore, followed by 0 or more alpha, number or underscore).
  # and return the matched word as string.
  #
  def word(expected='word expected')
    regexp(/[a-zA-Z_]\w*/, expected)
  end
  
  #
  # A parser that parses an integer
  # and return the matched integer as string.
  #
  def integer(expected='integer expected')
    regexp(/\d+(?!\w)/, expected)
  end
  
  #
  # A parser that parses a number (integer, or decimal number)
  # and return the matched number as string.
  #
  def number(expected='number expected')
    regexp(/\d+(\.\d+)?/, expected)
  end
  
  #
  # A parser that matches the given string, case insensitively.
  #
  def string_nocase(str, expected="'#{str}' expected")
    StringCaseInsensitiveParser.new(str, expected).setName(str)
  end
  
  #
  # A parser that succeeds when the current input
  # is a token with one of the the given token kinds.
  # If a block is given, the token text is passed to the block
  # as parameter, and the block return value is used as result.
  # Otherwise, the token object is used as result.
  #
  def token(*kinds, &proc)
    expected="#{kinds.join(' or ')} expected"
    recognizer = nil
    if kinds.length==1
      kind = kinds[0]
      recognizer = satisfies(expected) do |tok|
        tok.respond_to? :kind, :text and kind == tok.kind
      end
    else
      recognizer = satisfies(expected) do |tok|
        tok.respond_to? :kind, :text and kinds.include? tok.kind
      end
    end
    recognizer = recognizer.map{|tok|proc.call(tok.text)} if proc
    recognizer
  end
  
  #
  # A parser that parses a white space character.
  #
  def whitespace(expected="whitespace expected")
    satisfies(expected) {|c| Whitespaces.include? c}
  end
  
  #
  # A parser that parses 1 or more white space characters.
  #
  def whitespaces(expected="whitespace(s) expected")
    whitespace(expected).many_(1)
  end
  
  #
  # A parser that parses a line started with _start_.
  # nil is the result.
  #
  def comment_line start
    string(start) >> not_char(?\n).many_ >> char(?\n).optional >> value(nil)
  end
  
  #
  # A parser that parses a chunk of text started with _open_
  # and ended by _close_.
  # nil is the result.
  #
  def comment_block open, close
    string(open) >> not_string(close).many_ >> string(close) >> value(nil)
  end
  
  #
  # A lazy parser, when executed, calls the given block
  # to get a parser object and delegate the call to this lazily
  # instantiated parser.
  #
  def lazy(&block)
    LazyParser.new(block)
  end
  
  #
  # A parser that watches the current parser result without changing it.
  # The following assert will succeed:
  ##
  # char(?a) >> watch{|x|assert_equal(?a, x)}
  ##
  # watch can also be used as a handy tool to print trace information,
  # for example:
  ##
  # some_parser >> watch {puts "some_parser succeeded."}
  #
  def watch(&block)
    return one unless block
    WatchParser.new(block)
  end
  
  #
  # A parser that watches the current parser result without changing it.
  # The following assert will succeed:
  ##
  # char(?a).repeat(2) >> watchn{|x,y|assert_equal([?a,?a], [x,y])}
  ##
  # Slightly different from _watch_, _watchn_ expands the current parser result
  # before passing it into the associated block.
  #
  def watchn(&block)
    return one unless block
    WatchnParser.new(block)
  end
  
  # 
  # A parser that maps current parser result to a new result using
  # the given block.
  ##
  # Different from Parser#map, this method does not need to be combined
  # with any Parser object. It is rather an independent Parser object
  # that maps the _current_ parser result.
  ##
  # parser1.map{|x|...} is equivalent to parser1 >> map{|x|...}
  #
  def map(&block)
    return one unless block
    MapCurrentParser.new(block)
  end
  
  # 
  # A parser that maps current parser result to a new result using
  # the given block. If the current parser result is an array, the array
  # elements are expanded and then passed as parameters to the block.
  ##
  # Different from Parser#mapn, this method does not need to be combined
  # with any Parser object. It is rather an independent Parser object
  # that maps the _current_ parser result.
  ##
  # parser1.mapn{|x,y|...} is equivalent to parser1 >> mapn{|x,y|...}
  #
  def mapn(&block)
    return one unless block
    MapnCurrentParser.new(block)
  end
  
  private
  
  #
  # characters considered white space.
  #
  Whitespaces = " \t\r\n"
  
  def as_regexp ptn
    case ptn when String then Regexp.new(ptn) else ptn end
  end
  
  def as_char c
    case c when String then c else c.chr end
  end
  
  def as_num c
    case c when String: c[0] else c end
  end
  
  def as_list vals
    return vals unless vals.length==1
    val = vals[0]
    return vals unless val.kind_of? String
    val
  end
  
  extend self
end

end # module
