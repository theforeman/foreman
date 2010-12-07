require 'parser_test'
require 'sql'
require 'sql_parser'
class SqlTestCase < ParserTestCase
  include SqlParser
  def verify_sql(code, expected, parser)
    assert_equal(expected, make(parser).parse(code).to_s)
  end
  def verify_relation(code, expected)
    verify_sql(code, expected, relation)
  end
  def verify_predicate(code, expected)
    verify_sql(code, expected, predicate)
  end
  def testSimpleExpression
    verify_sql('1+2+3', '((1 + 2) + 3)', expression)
  end
  def testExpressionWithBool
    verify_sql('1+Case 2 when 1: x else dbo.y end', 
      '(1 + case 2 when 1: x else dbo.y end)', expression)
  end
  def testExpressionWithWildcard
    verify_sql('a.*', 'a.*', expression)
  end
  def testSimpleRelation
    verify_relation('select * from table1', 'select * from table1')
  end
  def testSimpleRelationWithStringLiteral
    verify_relation("select 'a',* from table1", "select 'a', * from table1")
  end
  def testSimpleRelationWithVar
    verify_relation("select $a,* from table1", "select $a, * from table1")
  end
  def testSimpleRelationWithQuotedName
    # the print out isn't really valid. but we care about parser, not the printer.
    verify_relation("select $a,* from [table 1]", "select $a, * from table 1")
  end
  def testSubRelation
    verify_relation('select * from (select a, b, c.* from c)', 
      'select * from (select a, b, c.* from c)')
  end
  def testSimpleRelationWithAlias
    verify_relation('select x.* from table1 x', 'select x.* from table1 AS x')
  end
  def testSubRelationWithAlias
    verify_relation('select * from ((select a, b, c.* from c)) x', 
      'select * from (select a, b, c.* from c) AS x')
  end
  def testRelationWithWhere
    verify_relation('select * from table where x=1', 
      'select * from table where x = 1')
  end
  def testRelationWithWhereAndDistinct
    verify_relation('select distinct * from table where x=1', 
      'select distinct * from table where x = 1')
  end
  def testRelationWithCompoundPredicateInWhereClause
    verify_relation('select * from table where x=1 and y=3', 
      'select * from table where (x = 1 and y = 3)')
  end
  def testRelationWithOrderBy
    verify_relation('select distinct * from table where x=1 order by x asc, y desc', 
      'select distinct * from table where x = 1 order by x, y desc')
  end
  def testRelationWithOrderByAndLimit
    verify_relation('select distinct * from table where x=1 order by x asc, y desc limit 5', 
      'select distinct * from table where x = 1 order by x, y desc limit 5')
  end
  def testRelationWithGroupByWithoutHaving
    verify_relation('select distinct * from table where x=1 group by x, y order by x asc, y desc', 
      'select distinct * from table where x = 1 group by x, y order by x, y desc')
  end
  def testRelationWithGroupByWithHaving
    verify_relation('select distinct * from table where x=1 group by x, y having x!=y order by x asc, y desc', 
      'select distinct * from table where x = 1 group by x, y having x <> y order by x, y desc')
  end
  def testRelationWithSimpleJoin
    verify_relation('select * from table1 t1 inner join table2 t2 on t1.a=t2.b where x=1', 
      'select * from table1 AS t1 inner join table2 AS t2 on t1.a = t2.b where x = 1')
  end
  def testRelationWithMultiJoins
    verify_relation('select * from table1 t1 inner join table2 t2 right outer join table3 on t2.x>t3.y on t1.a=t2.b cross join table3 where x=1', 
      'select * from table1 AS t1 inner join table2 AS t2 right join table3 on t2.x > t3.y on t1.a = t2.b cross join table3 where x = 1')
  end
  def testRelationWithExists
    verify_relation('select 1 from table1 where exists(select id from table2 where x=name)',
      'select 1 from table1 where exists(select id from table2 where x = name)')
  end
  def testRelationWithIn
    verify_relation('select 1 from table1 where x in(1,2,3)',
      'select 1 from table1 where x in (1, 2, 3)')
  end
  def testRelationWithNotIn
    verify_relation('select 1 from table1 where x not in(1,2,3)',
      'select 1 from table1 where x not in (1, 2, 3)')
  end
  def testRelationWithInRelation
    verify_relation('select 1 from table1 where x in(select * from table)',
      'select 1 from table1 where x in (select * from table)')
  end
  def testRelationWithNotInRelation
    verify_relation('select 1 from table1 where x not in table',
      'select 1 from table1 where x not in (table)')
  end
  def testRelationWithNotInRelationAndAmbiguousSubRelation
    verify_relation('select 1 from table1 where x not in (table)',
      'select 1 from table1 where x not in (table)')
  end
  def testRelationWithBetween
    verify_relation('select 1 from table1 where x between a and b',
      'select 1 from table1 where x between a and b')
  end
  def testRelationWithNotBetween
    verify_relation('select 1 from table1 where x not between (a,b)',
      'select 1 from table1 where x not between a and b')
  end
  def testRelationWithGroupCompare
    verify_relation('select 1 from table1 where not (a,b,c)>(1,2,3)',
      'select 1 from table1 where (not (a, b, c) > (1, 2, 3))')
  end
  def testUnion
    verify_relation('select * from table1 where a=2 union select * from table2 where a=1',
      'select * from table1 where a = 2 union select * from table2 where a = 1')
  end
  def testAndOrNot
    verify_predicate '1>1 or 1<=1 and not true', '(1 > 1 or (1 <= 1 and (not true)))'
  end
end