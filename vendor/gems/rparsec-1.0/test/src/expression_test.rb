require 'import'
import :parsers, :functors, :expressions
require 'parser_test'

class ExpressionParserTest < ParserTestCase
  include Functors
  def setup
    @use_around = true
  end
  def around(p)
    return p unless @use_around
    delim = whitespace.many_
    p << delim;
  end
  def negate
    around(char('-')) >> value(Neg)
  end
  def positive
    around(char('+')) >> value(Id)
  end
  def increment
    around(string('++') >> value(Inc))
  end
  def decrement
    around(string('--')) >> value(Dec)
  end
  def plus
    around(char('+')) >> value(Plus)
  end
  def minus
    around(char('-')) >> value(Minus)
  end
  def mul
    around(char('*')) >> value(Mul)
  end
  def space_mul
    not_among('+-*/%').peek >> value(Mul)
  end
  def div
    around(char('/')) >> value(Div)
  end
  def rdiv
    around(str('//')) >> value(Div)
  end
  def mod
    around(char('%')) >> value(Mod)
  end
  def lparen
    around(char('('))
  end
  def rparen
    around(char(')'))
  end
  def int
    around(integer).map(&To_i)
  end
  def testPrefix
    parser = whitespace.many_ >> int.prefix(negate) << eof
    assertParser(' - -3 ', 3, parser)
    assertParser(' 3', 3, parser)
    assertParser('3 ', 3, parser)
    assertParser('-3', -3, parser)
    assertError(' - -', 'integer expected', parser, 4)
    assertError(' - -5 3', 'EOF expected', parser, 6)
  end
  def testPostfix
    parser = whitespace.many_ >> int.postfix(increment) << eof
    assertParser(' 3++ ++', 5, parser)
    assertParser('3++++ ', 5, parser)
    assertParser(' 3', 3, parser)
    assertError(' ++', 'integer expected', parser, 1)
    assertError('5++ 3', 'EOF expected', parser, 4)
  end
  def testInfixn
    parser = whitespace.many_ >> int.infixn(plus) << eof
    assertParser(' 1 + 2 ', 3, parser)
    assertParser('1 + 2 ', 3, parser)
    assertError('1+2 +3', 'EOF expected', parser, 4)
  end
  def testInfixl
    parser = whitespace.many_ >> int.infixl(minus) << eof
    assertParser(' 1-2 -3 ', -4, parser)
    assertParser('1 - 2 ', -1, parser)
    assertParser('1  ', 1, parser)
    assertError('1-2-3-', 'integer expected', parser, 6)
  end
  def testInfixr
    parser = whitespace.many_ >> int.infixr(minus) << eof
    assertParser(' 1-2 -3 ', 2, parser)
    assertParser(' 1-2 -3-4 ', -2, parser)
    assertParser('1 - 2 ', -1, parser)
    assertParser('1  ', 1, parser)
    assertError('1-2-3-', 'integer expected', parser, 6)
  end
  def testExpression
    @use_around = false
    ops = OperatorTable.new do |tbl|
      tbl.infixl(plus, 20)
      tbl.infixl(minus, 20)
      tbl.infixl(mul, 40)
      tbl.infixl(space_mul, 40)
      tbl.infixl(div, 40)
      tbl.prefix(negate, 60)
      tbl.prefix(positive, 60)
      tbl.postfix(increment, 50)
      tbl.postfix(decrement, 50)
      tbl.infixr(rdiv, 40)
    end
    expr = nil
    term = int | char(?() >> lazy{expr} << char(?))
    delim = whitespace.many_
    expr = delim >> Expressions.build(term, ops, delim)
    
    assertParser('1', 1, expr)
    assertParser('1+2', 3, expr)
    assertParser('(1-2)', -1, expr)
    assertParser('2-3* 2', -4, expr)
    assertParser("\n ((2-3 )*-+2--) ", 3, expr)
    assertParser('((2-3 )*-+2--/2//2) ', 3, expr)
    assertParser('((2-3 )*-+2--/2//2--) ', 1, expr)
    assertParser('((2-3 )*-+2--//4//2) ', 2, expr)
    assertParser('((2-3 )*-+2--/2/2) ', 0, expr)
  end
end