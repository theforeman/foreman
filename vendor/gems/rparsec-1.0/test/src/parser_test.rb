require 'import'
require 'rubyunit'
import :parsers, :functors

include RParsec

class ParserTestCase < RUNIT::TestCase
  include Functors
  include Parsers
  def assertParser(code, expected, parser)
    assert_equal(expected, parser.parse(code))
  end
  def assertError(code, expected, parser, index=0, line=1, col=1+index)
    begin
      parser.parse(code)
      assert_fail("error should have happened")
      rescue ParserException => e
        assert_equal(index, e.index)
        msg = expected
        msg = add_encountered(msg, current(code,index)) << " at line #{line}, col #{col}." unless expected.include? 'at line'
        assert_equal(msg, e.message)
    end
  end
  def assertGrammar(code, expected, lexer, grammar)
    assertParser(code, expected, lexer.nested(grammar))
  end
  def assertGrammarError(code, expected, token_name, lexer, grammar, index=0, line=1, col=1+index)
    parser = lexer.nested(grammar)
    begin
      parser.parse(code)
      assert_fail("error should have happened")
      rescue ParserException => e
        assert_equal(index, e.index)
        msg = expected
        msg = "#{msg}, #{token_name}" << " at line #{line}, col #{col}." unless expected.include? 'at line'
        assert_equal(msg, e.message)
    end
  end
  def current(code, index)
    return "EOF" if code.length <= index
    c = code[index]
    if c.kind_of? Fixnum
      "'"<<c<<"'"
    else
      c.to_s
    end
  end
  def add_encountered(msg, encountered)
    result = msg.dup
    result << ', ' unless msg.strip.length == 0 || msg =~ /.*(\.|,)\s*$/
    "#{result}#{encountered}"
  end
end