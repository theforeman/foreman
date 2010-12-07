require 'import'
import :misc

include RParsec
class Module
  include DefHelper
end
class Expr
  def self.binary(*ops)
    ops.each do |op|
      define_method(op) do |other|
        BinaryExpr.new(self, op, other)
      end
    end
  end
  binary :+,:-,:*,:/,:%
  def -@
    PrefixExpr.new(:-, self)
  end
  def self.compare(*ops)
    ops.each do |op|
      define_method(op) do |other|
        ComparePredicate.new(self, op, other)
      end
    end
  end
  compare :'==', :'>', :'<', :'>=', :'<='
end
class LiteralExpr < Expr
  def_readable :lit
  def to_s
    @lit.to_s
  end
end
class VarExpr < Expr
  def_readable :name
  def to_s
    "$#{name}"
  end
end
class WordExpr < Expr
  def_readable :name
  def to_s
    name
  end
end
class QualifiedColumnExpr < Expr
  def_readable :owner, :col
  def to_s
    "#{owner}.#{col}"
  end
end
class WildcardExpr < Expr
  Instance = WildcardExpr.new
  def to_s
    '*'
  end
end
class BinaryExpr < Expr
  def_readable :left, :op, :right
  def to_s
    "(#{left} #{op} #{right})"
  end
end
class PostfixExpr < Expr
  def_readable :expr, :op
  def to_s
    "(#{expr} #{op})"
  end
end
class PrefixExpr < Expr
  def_readable :op, :expr
  def to_s
    "(#{op} #{expr})"
  end
end
def cases_string cases, default, result
    cases.each do |cond, val|
      result << " when #{cond}: #{val}"
    end
    unless default.nil?
      result << " else #{default}"
    end
    result << " end"
    result
end
class SimpleCaseExpr < Expr
  def_readable :expr, :cases, :default
  def to_s
    cases_string cases, default, "case #{expr}"
  end
end
class CaseExpr < Expr
  def_readable :cases, :default
  def to_s
    cases_string cases, default, 'case'
  end
end


############Predicate########################
class Predicate
end

class ComparePredicate < Predicate
  def_readable :left, :op, :right
  def to_s
    "#{left} #{op_name} #{right}"
  end
  def op_name
    case op when :"!=": "<>" else op.to_s end
  end
end
class CompoundPredicate < Predicate
  def_readable :left, :op, :right
  def to_s
    "(#{left} #{op} #{right})"
  end
end
class NotPredicate < Predicate
  def_readable :predicate
  def to_s
    "(not #{predicate})"
  end
end
class ExistsPredicate < Predicate
  def_readable :relation
  def to_s
    "exists(#{relation})"
  end
end
class NotExistsPredicate < Predicate
  def_readable :relation
  def to_s
    "not exists(#{relation})"
  end
end
class InRelationPredicate < Predicate
  def_readable :expr, :relation
  def to_s
    "#{expr} in (#{relation})"
  end
end
class NotInRelationPredicate < Predicate
  def_readable :expr, :relation
  def to_s
    "#{expr} not in (#{relation})"
  end
end
class InPredicate < Predicate
  def_readable :expr, :vals
  def to_s
    "#{expr} in (#{vals.join(', ')})"
  end
end
class NotInPredicate < Predicate
  def_readable :expr, :vals
  def to_s
    "#{expr} not in (#{vals.join(', ')})"
  end
end
class BetweenPredicate < Predicate
  def_readable :expr, :from, :to
  def to_s
    "#{expr} between #{from} and #{to}"
  end
end
class NotBetweenPredicate < Predicate
  def_readable :expr, :from, :to
  def to_s
    "#{expr} not between #{from} and #{to}"
  end
end
class GroupComparisonPredicate < Predicate
  def_readable :group1, :op, :group2
  def to_s
    "#{list_exprs group1} #{op} #{list_exprs group2}"
  end
  def list_exprs exprs
    "(#{exprs.join(', ')})"
  end
end
#############Relations######################

class OrderElement
  def_readable :expr, :asc
  def to_s
    result = "#{expr}"
    unless asc
      result << ' desc'
    end
    result
  end
end
class GroupByClause
  def_readable :exprs, :having
  def to_s
    result = exprs.join(', ')
    unless having.nil?
      result << " having #{having}"
    end
    result
  end
end
class Relation
  def as_inner
    to_s
  end
end
class TableRelation < Relation
  def_readable :table
  def to_s
    table
  end
end
class SelectRelation < Relation
  def_readable :select, :distinct, :from, :where, :groupby, :orderby
  def to_s
    result = "select "
    if distinct
      result << 'distinct '
    end
    result << "#{select.join(', ')} from #{from.as_inner}"
    unless where.nil?
      result << " where #{where}"
    end
    unless groupby.nil?
      result << " group by #{groupby}"
    end
    unless orderby.nil?
      result << " order by #{orderby.join(', ')}"
    end
    result
  end
  def as_inner
    "(#{self})"
  end
end
class LimitRelation < Relation
  def_readable :rel, :limit
  def to_s
    "#{rel} limit #{limit}"
  end
end
class JoinRelation < Relation
  def_readable :kind, :left, :right, :on
  def to_s
    "#{left} #{kind} join #{right} on #{on}"
  end
end
class CrossJoinRelation < Relation
  def_readable :left, :right
  def to_s
    "#{left} cross join #{right}"
  end
end
class AliasRelation < Relation
  def_readable :relation, :name
  def to_s
    "#{relation.as_inner} AS #{name}"
  end
end
class UnionRelation < Relation
  def_readable :left, :all, :right
  def to_s
    "#{left} union #{case when all: 'all ' else '' end}#{right}"
  end
end