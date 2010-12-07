require 'import'
import :parsers, :functors, :expressions
require 'parser_test'

class SExpressionTestCase < ParserTestCase
  def delim
    whitespace.many_
  end
  def ignore parser
    parser << delim
  end
  def lparen
    ignore(char('('))
  end
  def rparen
    ignore(char(')'))
  end
  def parser
    expr = nil
    lazy_expr = lazy{expr}
    term = number.map(&To_f) | lparen >> lazy_expr << rparen
    binop = char('+') >> Plus | char('-') >> Minus | char('*') >> Mul | char('/') >> Div
    binop = ignore binop
    term = ignore term
    binary = sequence(binop, lazy_expr, lazy_expr) do |op, e1, e2|
      op.call(e1, e2)
    end
    expr = delim >> (term | binary)
  end
  def test1
    assertParser('- (+ 1 * 2 2.0) (1)', 4, parser)
  end
end