require 'import'
import :parsers, :operators, :functors
require 'parser_test'

class OperatorTestCase < ParserTestCase
  Ops = Operators.new(%w{++ + - -- * / ~}, &Id)
  def verifyToken(src, op)
    verifyParser(src, op, Ops[op])
  end
  def verifyParser(src, expected, parser)
    assertParser(src, expected, Ops.lexer.lexeme.nested(parser))
  end
  def testAll
    verifyToken('++ -', '++')
    verifyParser('++ + -- ++ - +', '-', 
      (Ops['++']|Ops['--']|Ops['+']).many_ >> Ops['-'])
  end
  def testSort
    assert_equal(%w{+++ ++- ++ + --- -- -}, Operators.sort(%w{++ - + -- +++ ++- ---}))
  end
end