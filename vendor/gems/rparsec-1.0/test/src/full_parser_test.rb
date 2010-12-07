require 'import'
import :parsers, :keywords, :operators, :functors, :expressions
require 'parser_test'

class FullParserTest < ParserTestCase
  def calculate_simple_cases(val, cases, default)
    cases.each do |cond, consequence|
      # cond, consequence = *cs
      return consequence if cond == val
    end
    default
  end
  def calculate_full_cases(cases, default)
    cases.each do |cond, consequence|
      return consequence if cond
    end
    default
  end
  def parser
    keywords = Keywords.case_sensitive(%w{case when else end and or not true false})
    ops = Operators.new(%w{+ - * / % ++ -- == > < >= <= != : ( )})
    lexer = integer.token(:int)|keywords.lexer|ops.lexer
    delim = whitespaces |comment_line('#')
    lexeme = lexer.lexeme(delim) << eof
    expr = nil
    lazy_expr = lazy{expr}
    compare = ops['>'] >> Gt | ops['<'] >> Lt | ops['>='] >> Ge | ops['<='] >> Le |
      ops['=='] >> Eq | ops['!='] >> Ne
    comparison = sequence(lazy_expr, compare, lazy_expr) {|e1,f,e2|f.call(e1,e2)}
    bool = nil
    lazy_bool = lazy{bool}
    bool_term = keywords[:true] >> true | keywords[:false] >> false |
      comparison | ops['('] >> lazy_bool << ops[')']
    bool_table = OperatorTable.new.
      infixl(keywords[:or] >> Or, 20).
      infixl(keywords[:and] >> And, 30).
      infixl(keywords[:not] >> Not, 30)
    
    bool = Expressions.build(bool_term, bool_table)
    simple_case = sequence(keywords[:when], lazy_expr, ops[':'], lazy_expr) do |w,cond,t,val|
      [cond, val]
    end
    full_case = sequence(keywords[:when], bool, ops[':'], lazy_expr) do |w,cond,t,val|
      [cond, val]
    end
    default_case = (keywords[:else] >> lazy_expr).optional
    simple_when_then = sequence(lazy_expr, simple_case.many, default_case, 
      keywords[:end]) do |val, cases, default|
      calculate_simple_cases(val, cases, default)
    end
    full_when_then = sequence(full_case.many, default_case, keywords[:end]) do |cases, default|
      calculate_full_cases(cases, default)
    end
    case_expr = keywords[:case] >> (simple_when_then | full_when_then)
    
    term = token(:int, &To_i) | (ops['('] >> lazy_expr << ops[')']) | case_expr
    table = OperatorTable.new.
      infixl(ops['+'] >> Plus, 20).
      infixl(ops['-'] >> Minus, 20).
      infixl(ops['*'] >> Mul, 30).
      infixl(ops['/'] >> Div, 30).
      postfix(ops['++'] >> Inc, 40).
      postfix(ops['--'] >> Dec, 40).
      prefix(ops['-'] >> Neg, 50)
    expr = Expressions.build(term, table)
    lexeme.nested(expr << eof)
  end
  def verify(code, expected=eval(code))
    assertParser(code, expected, self.parser)
  end
  def testNumber
    verify(' 1')
  end
  def testSimpleCalc
    verify('1 - 2')
  end
  def testComplexCalculationWithComment
    verify('2*15/-(5- -2) #this is test')
  end
  def testSimpleCaseWhen
    verify('case 1 when 1: 0 else 1 end')
  end
  def testSimpleCaseWhenWithRegularCalc
    verify('case 1 when 1*1: (1-2) when 3:4 end+1')
  end
  def testFullCaseWhen
      assertParser('3*case when 1==0 and 1==1: 1 when 1==1 : 2 end', 6, parser)
    begin
      parser.parse('3*case when (1==0 and 1==1): 1 when 1==1 then 2 end')
      fail('should have failed')
      rescue ParserException => e
        assert(e.message.include?(': expected, then at line 1, col 42'))
    end
  end
end