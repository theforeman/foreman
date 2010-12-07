require 'import'
import :parsers
require 'parser_test'

class SimpleParserTest < ParserTestCase
  def testValue
    assertParser('', 1, value(1))
  end
  def testFail
    assertError('', 'wrong', failure('wrong'))
  end
  def testGoodPlusGoodReturnFirst
    assertParser('', 1, value(1)|value(2))
  end
  def testFailPlusGoodReturnGood
    assertParser('', 2, failure('wrong')|value(2))
  end
  def testFailPlusFailFailsWithFirstError
    assertError('', 'wrong', failure('wrong') | failure('wrong too'))
  end
  def testFailBreaksSeq
    assertError('', 'wrong', failure('wrong') >> value(2))
  end
  def testGoodSeqGoodReturnsSecond
    assertParser('', 2, value(1).seq(value(2)))
  end
  def testGoodSeqFailFails
    assertError('', 'wrong', value(1) >> failure('wrong'))
  end
  def testFailSeqFailFails
    assertError('', 'wrong', failure('wrong') >> failure('wrong too'))
  end
  def testMap
    assertParser('', 2, value(1).map{|x|x*2})
    relative = Proc.new{|x|x-?a}
    assertParser('b', 1, char('b').map(&relative))
  end
  def testMapOnFailFails
    assertError('', 'wrong', failure('wrong').map{|x|x*2})
  end
  def testBinds
    assertParser('', 3, value(1).bind do |a|
      value(2).bind{|b|value(a+b)}
    end)
    assertParser('', 2, value(1).repeat(2).bindn do |a,b|
      value(a+b)
    end)
  end
  def testSum
    assertParser('', 1, sum(value(1), value(2), value(3)))
  end
  def testNestedErrorRecoveredShouldNotAppearInFinalError
    assertError('', 'wrong too', (failure('wrong') | value(1)) >> failure('wrong too'))
  end
  def testSatisfies
    assertParser('abc', ?a, Parsers.satisfies('a expected'){|c|c==(?a)})
    assertError('abc', 'b expected', Parsers.satisfies('b expected'){|c|c==(?b)})
  end
  def testIs
    assertParser('abc', ?a, is(?a))
    assertError('abc', '98 expected', is(?b))
  end
  def testIsnt
    assertParser('abc', ?a, isnt(?b))
    assertError('abc', '97 unexpected', isnt(?a))
    assertError('abc', "'b' unexpected", not_char(?b) >> not_char('b'), 1)
  end
  def testCharAndEof
    assertParser('abc', ?c, char('a') >> char('b') >> char('c') >> eof())
  end
  def testAre
    assertParser('abc', 'ab', string('ab'))
    assertError('abc', '"ab" expected', char('a') >> str('ab'), 1)
  end
  def testSequence
    assertParser('abc', ?c, sequence(char(?a),char('b'),char('c')))
    a = ?a
    relative = proc {|c|c-a}
    parser = sequence(
      char('c').map(&relative), 
      char('b').map(&relative), 
      char('a').map(&relative)
    ){|x,y,z| x+y+z}
    assertParser('cba', 3, parser)
  end
  def testPlusAutomaticallyRecoverInputConsumption
    assertError('abc', '"bcd" expected', char('a') >> str('bcd').plus(str('abc')), 1)
    assertParser('abc', 'abc', char('a') >> str('bcd') | str('abc'))
    assertError('abc', "'d' expected", char('a') >> char(?b) >> char(?d) | char(?a) >> char(?c) | str('abd'), 2)
  end
  def testLookaheadRecoversInputConsumption
    assertParser('abc', 'abc', (char('x') | char('a') >> str('bcd') | str('abc') | char('x')).lookahead(2))
  end
  def testLocator
    line, col = CodeLocator.new("abc").locate(2)
    assert_equal([1,3],[line,col])
  end
  def testInputConsumptionBiggerThanLookaheadShouldFail
    assertError('abc', "'d' expected", sum(str('ab')>>char('d'), str('abc')).lookahead(2), 2)
  end
  
  def testInputConsumptionDoesNotFailForAlt
    assertParser('abc', 'abc', alt(str('ab')>>char('d'), str('abc')))
  end
  def testAtomParserIsAlwaysRecoverable
    assertParser('abc', 'abc', (str('ab')>>char('d')).atomize | str('abc'))
  end
  def testSimpleNot
    assertParser('abc', nil, str('abd').not)
    assertError('abc', 'abc unexpected', str('abc').not)
  end
  def testNotDoesntConsume
    assertParser('abc', 'abc', ~str('abc') | str('abc'))
  end
  def testNotDoesntRecoverAlreadyConsumedInputWhenFailingUnlessUsingLookahead
    parser = (char('a') >> str('abc')).not
    assertError('abc', '"abc" expected', parser, 1)
    parser = parser.lookahead(2)
    assertParser('abc', nil, parser)
  end
  def testLookeaheadUsedInPlusCanBeUsedByNot
    parser = (char('a') >> str('abc') | char('a') >> str('bcd')).lookahead(2)
    # assertError('abc', '"abc" expected or "bcd" expected', parser, 1)
    assertError('abc', '"abc" expected', parser, 1)
    assertParser('abc', nil, parser.not)
  end
  def testNotString
    assertParser('abc', ?a, not_string('abcd'))
    assertError('abc', '"abc" unexpected', not_string('abc'))
    assertError('aabcd', '"abc" unexpected', not_string('abc')*2, 1)
  end
  def testArent
    assertError('abc', 'abc unexpected', arent('abc'))
    assertParser('abc', ?a, arent('abcd'))
  end
  def testAmong
    assertParser('abc', ?a, among(?b, ?a))
    assertParser('abc', ?a, among('ba'))
    assertError('abc', "one of [98, 99] expected", among(?b,?c))
  end
  def testNotAmong
    assertError('abc', "one of [98, 97] unexpected", not_among(?b, ?a))
    assertParser('abc', ?a, not_among(?b,?c))
  end
  def testGetIndex
    assertParser('abc', 1, char('a') >> get_index)
  end
  def testMultilineErrorMessage
    assertError("ab\nc", "'d' expected", str("ab\nc") >> char(?d), 4, 2, 2)
  end
  def testExpect
    assertError("abc", 'word expected', str("abcd").expect("word expected"))
  end
  def testExpectDoesntRecover
    assertError('abc', '"bcd" expected', (char(?a) >> str('bcd')).expect('word expected'), 1)
  end
  def testLonger
    assertParser('abc', 'abc', longer(char('a')>>char('b'), str('abc')))
  end
  def testShorter
    assertParser('abc', ?b, shorter(char('a')>>char('b')>>char('c'), char(?a) >> char(?c), char('a')>>char('b')))
  end
  def testLongerReportsDeepestError
    assertError('abc', "'d' expected", 
      longer(char('a')>>char('b')>>char('d'), char('a')>>char('c')), 2)
  end
  def testShorterReportsDeepestError
    assertError('abc', "'d' expected", 
      shorter(char('a')>>char('b')>>char('d'), char('a')>>char('c')), 2)
  end
  def testFollowed
    assertParser('abc', ?a, char(?a)<<char(?b))
  end
  def testEof
    assertParser('abc', 'abc', str('abc') << eof)
    assertError('abc', 'EOF expected', str('ab') << eof, 2)
  end
  def testAny
    assertParser('abc', ?a, any)
    assertError('abc', '', str('abc')<<any, 3)
  end
  def testRepeat_
    assertParser('abc', ?c, any*3)
    assertError('abc', '', any.repeat_(4), 3)
    assertError('abc', "'d' expected", any*3 >> char(?d), 3)
  end
  def testMany_
    assertParser('abc', ?c, any.many_)
    assertParser('abc', ?c, any.many_(3))
    assertError('abc', "a..b expected", range(?a, ?b).many_(3), 2)
    assertParser('abc', ?b, range(?a, ?b).many_())
    assertParser('abc', 1, value(1).many_())
    assertError('abc', "'b' expected", value(1).many_ >> char(?b))
  end
  def testNonDeterministicRepeat_
    assertParser('abc', ?c, any.repeat_(3,4))
    assertParser('abc', ?b, any.some_(2))
    assertError('abc', "min=4, max=3", range(?a, ?b).repeat_(4,3))
    assertParser('abc', ?b, range(?a, ?b).some_(10))
    # should we break for infinite loop? they are not really infinite for some.
    assertError('abc', "'b' expected", value(1).some_(2) >> char(?b))
    assertParser('abc', nil, any.some_(0))
  end
  def testRange
    assertParser('abc', ?a, range(?a, ?c))
    assertError('abc', 'd..e expected', range(?d, 'e'))
    assertError('abc', 'c expected', range(?c, ?b, 'c expected'))
  end
  def testBetween
    assertParser('abc', ?b, char(?a) >> char('b') << char(?c))
  end
  def testRepeat
    assertParser('abc', [?a, ?b, ?c], any.repeat(3))
    assertParser('abc', [?a, ?b], any.repeat(2))
    assertParser('abc', [], any.repeat(0))
    assertError('abc', '', any.repeat(4), 3)
    assertError('abc', "a..b expected", range(?a, ?b).repeat(3), 2)
  end
  def testMany
    assertParser('abc', [?a, ?b, ?c], any.many)
    assertParser('abc', [?a, ?b], range(?a, ?b).many)
    assertError('abc', '', any.many(4), 3)
  end
  def testSome
    assertParser('abc', [?a, ?b, ?c], any.some(3))
    assertParser('abc', [?a, ?b], any.some(2))
    assertError('abc', "a..b expected", range(?a,?b).repeat(3,4), 2)
    assertParser('abc', ?c, any.some(2) >> any)
  end
  def testSeparated1
    assertParser('a,b,c', [?a,?b,?c], any.separated1(char(',')))
    assertParser('abc', [?a], any.separated1(char(',')))
    assertError('a,', "'a' expected", char('a').separated1(char(',')), 2)
    assertError('', '', any.separated1(char(',')))
  end
  def testSeparated
    assertParser('a,b,c', [?a,?b,?c], any.separated(char(',')))
    assertParser('abc', [?a], any.separated(char(',')))
    assertError('a,', "'a' expected", char('a').separated(char(',')), 2)
    assertParser('', [], any.separated(char(',')))
  end
  def testValueCalledImplicitlyForOverloadedOrOperator
    assertParser('abc', 1, char(',')|1)
  end
  def testOptional
    assertParser('abc', nil, char(?,).optional)
    assertParser('abc', 'xyz', char(?,).optional('xyz'))
    assertError('abc', "'.' expected", (any.some_(2) >> char(?.)).optional, 2)
    # assertParser('abc', nil, (any.some_(2) >> char(?.)).optional)
  end
  def testThrowCatch
    assertParser('abc', :hello, (char('a')>>throwp(:hello)).catchp(:hello))
    assertParser('abc', ?a, char(?a).catchp(:hello))
  end
  def testDelimited1
    assertParser('a,b,c', [?a,?b,?c], any.delimited1(char(',')))
    assertParser('abc', [?a], any.delimited1(char(',')))
    assertParser('a,', [?a], char('a').delimited1(char(',')))
    assertError('', '', any.delimited1(char(',')))
    assertParser('a,b', ?b, char(?a).delimited1(char(',')) >> char(?b))
  end
  def testDelimited
    assertParser('a,b,c', [?a,?b,?c], any.delimited(char(',')))
    assertParser('abc', [?a], any.delimited(char(',')))
    assertParser('a,b,', [?a,?b], range('a', 'b').delimited(char(',')))
    assertParser('', [], any.delimited(char(',')))
    assertParser('a,b', ?b, char(?a).delimited(char(',')) >> char(?b))
  end
  def testRegexp
    assertParser('abc', 'ab', regexp('(a|b)+', 'a or b expected'))
    assertError('abc', 'x or y expected', char('a') >> regexp('(x|y)+', 'x or y expected'), 1)
  end
  def testWord
    assertParser('abc123', 'abc123', word)
    assertError('1abc123', 'word expected', word)
    assertParser('abc a123', 'a123', word >> char(' ') >> word)
  end
  def testInteger
    assertParser('123', '123', integer)
    assertError('a123', 'integer expected', integer)
    assertError('123a', 'integer expected', integer)
  end
  def testNumber
    assertParser('123.456', '123.456', number)
    assertParser('0123', '0123', number)
    assertParser('123.2.5', '5', number >> char('.') >> number)
    assertError('a123', 'number expected', number)
  end
  def testStringCaseInsensitive
    assertParser('abc', 'abc', string_nocase('ABc'))
    assertError('abc', "'ABc' expected", string_nocase('A') >> string_nocase('ABc'), 1)
  end
  def testFragment
    assertParser('abc', 'bc', any >> (any*2).fragment)
    assertError('abc', "'b' expected", any >> (char('b')*2).fragment, 2)
  end
  def testToken
    assertGrammar('abc', 'abcabc', word.token(:word).many, token(:word){|x|x+x})
    assertGrammar('abc defg', 1, word.token(:word).delimited(char(' ')), token(:word) >> token(:word) >> value(1))
    assertGrammarError('abc defg', 'integer expected', 'defg', word.token(:word).delimited(char(' ')), 
      token(:word) >> token(:integer), 4)
  end
  def testGetIndexFromGrammar
    assertGrammar('abc cdef', 1, word.token(:word).many, token(:word) >> get_index)
  end
  def testWhitespace
    assertParser(' ', ?\s, whitespace)
    assertParser("\t", ?\t, whitespace)
    assertParser("\n", ?\n, whitespace)
    assertError('abc', 'whitespace expected', whitespace)
  end
  def testWhitespaces
    assertParser('   ', ?\s, whitespaces)
    assertParser("\n\t", ?\t, whitespaces)
    assertError("\n \tabc ", "whitespace(s) expected, 'a' at line 2, col 3.", whitespaces >> whitespaces, 3)
  end
  def testCommentLineWithLexeme
   assertParser('#abc', nil, comment_line('#'))
   code = <<-HERE
      //HELLO
      123
    HERE
    delim = (comment_line('//')|whitespaces)
    assertParser(code, ["123"], integer.lexeme(delim) >> eof)
    assertParser('//', nil, comment_line('//'))
    code = '123'
    assertParser(code, ["123"], integer.lexeme(delim) >> eof)
    
  end
  def testBlockComment
    cmt =comment_block('/*', '*/')
    assertParser('/*abc*/', nil, cmt)
    assertError('/*abcd ', '"*/" expected', cmt, 7)
  end
  def testLazy
    expr = nil
    lazy_expr = lazy{expr}
    expr = integer.map(&To_i) | char('(') >> lazy_expr << char(')')
    assertParser('123', 123, expr)
    assertParser('((123))', 123, expr)
  end
  def testPeek
    assertParser('abc', ?a, char('a').peek)
    assertParser('abc', ?a, char('a').peek.repeat_(2))
    assertError('abc', "'b' expected", char('a').peek >> char('b'))
  end
  def testParserTypeCheck
    verifyTypeMismatch(:plus, '1st', Parser, String) do
      char('a').plus('a')
    end
    verifyTypeMismatch(:seq, '1st', Parser, String) do
      char('a').seq('a')
    end
    verifyTypeMismatch(:followed, '1st', Parser, String) do
      char('a') << 'a'
    end
    verifyTypeMismatch(:sequence, '2nd', Parser, Fixnum) do
      sequence(char('a'), 1, 2)
    end
    verifyTypeMismatch(:sum, '2nd', Parser, Fixnum) do
      sum(char('a'), 1, 2)
    end
    verifyTypeMismatch(:longest, '2nd', Parser, Fixnum) do
      longest(char('a'), 1, 2)
    end
    verifyTypeMismatch(:shortest, '2nd', Parser, Fixnum) do
      shortest(char('a'), 1, 2)
    end
  end
  def testSetIndex
    parser = get_index.bind do |ind|
      char('a') << set_index(ind)
    end
    assertParser('abc', [?a,?a,?a], parser.repeat(3))
  end
  def testMapn
    assertParser('abc', ?b, any.repeat(3).mapn{|a,b,c|c-b+a})
  end
  def testWatch
    i = nil
    assertParser('abc', ?b, any.repeat_(2) >> watch{i=1});
    assert_equal(1, i)
    assertParser('abc', ?b, any.repeat_(2) >> 
      watch{|x|assert_equal(?b, x)}
    )
    assertParser('abc', [?a,?b], any.repeat(2) >> 
      watchn do |x,y|
        assert_equal(?a, x)
        assert_equal(?b, y)
      end
    )
    assertParser('abc', ?b, any.repeat_(2) >> watch);
  end
  def testMapCurrent
    assertParser('abc', ?b, any >> map{|x|x+1})
    assertParser('abc', ?a, any >> map)
    assertParser('abc', ?a, any.map)
    assertParser('abc', ?a, any.mapn)
  end
  def testMapnCurrent
    assertParser('abc', ?a, any.repeat(2) >> mapn{|a,_|a})
    assertParser('abc', ?c, any.repeat_(2) >> mapn(&Inc))
    assertParser('abc', [?a,?b], any.repeat(2) >> mapn)
  end
  def verifyTypeMismatch(mtd, n, expected, actual)
    begin
      yield
      assert_fail('should have failed with type mismatch')
      rescue ArgumentError => e
        assert_equal("#{actual} assigned to #{expected} for the #{n} argument of #{mtd}.",
          e.message)
    end
  end
  def verifyArrayTypeMismatch(mtd, n_arg, n_elem, expected, actual)
    begin
      yield
      assert_fail('should have failed with type mismatch')
      rescue ArgumentError => e
        assert_equal("#{actual} assigned to #{expected} for the #{n_elem} element of the #{n_arg} argument of #{mtd}.",
          e.message)
    end
  end
end
