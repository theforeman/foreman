#!/usr/bin/env ruby -w

require 'rubygems'
require 'sexp_processor'

class Ruby2Ruby < SexpProcessor
  VERSION = '1.2.5'
  LINE_LENGTH = 78

  BINARY = [:<=>, :==, :<, :>, :<=, :>=, :-, :+, :*, :/, :%, :<<, :>>, :**]

  ##
  # Nodes that represent assignment and probably need () around them.

  ASSIGN_NODES = [
                  :dasgn,
                  :flip2,
                  :flip3,
                  :lasgn,
                  :masgn,
                  :attrasgn,
                  :op_asgn1,
                  :op_asgn2,
                  :op_asgn_and,
                  :op_asgn_or,
                  :return,
                 ]

  def initialize
    super
    @indent = "  "
    self.auto_shift_type = true
    self.strict = true
    self.expected = String

    @calls = []

    # self.debug[:defn] = /zsuper/
  end

  ############################################################
  # Processors

  def process_alias(exp)
    "alias #{process(exp.shift)} #{process(exp.shift)}"
  end

  def process_and(exp)
    "(#{process exp.shift} and #{process exp.shift})"
  end

  def process_arglist(exp) # custom made node
    code = []
    until exp.empty? do
      code << process(exp.shift)
    end
    code.join ', '
  end

  def process_args(exp)
    args = []

    until exp.empty? do
      arg = exp.shift
      case arg
      when Symbol then
        args << arg
      when Array then
        case arg.first
        when :block then
          asgns = {}
          arg[1..-1].each do |lasgn|
            asgns[lasgn[1]] = process(lasgn)
          end

          args.each_with_index do |name, index|
            args[index] = asgns[name] if asgns.has_key? name
          end
        else
          raise "unknown arg type #{arg.first.inspect}"
        end
      else
        raise "unknown arg type #{arg.inspect}"
      end
    end

    return "(#{args.join ', '})"
  end

  def process_array(exp)
    "[#{process_arglist(exp)}]"
  end

  def process_attrasgn(exp)
    receiver = process exp.shift
    name = exp.shift
    args = exp.empty? ? nil : exp.shift

    case name
    when :[]= then
      rhs = process args.pop
      "#{receiver}[#{process(args)}] = #{rhs}"
    else
      name = name.to_s.sub(/=$/, '')
      if args && args != s(:arglist) then
        "#{receiver}.#{name} = #{process(args)}"
      end
    end
  end

  def process_back_ref(exp)
    "$#{exp.shift}"
  end

  # TODO: figure out how to do rescue and ensure ENTIRELY w/o begin
  def process_begin(exp)
    code = []
    code << "begin"
    until exp.empty?
      src = process(exp.shift)
      src = indent(src) unless src =~ /(^|\n)rescue/ # ensure no level 0 rescues
      code << src
    end
    code << "end"
    return code.join("\n")
  end

  def process_block(exp)
    result = []

    exp << nil if exp.empty?
    until exp.empty? do
      code = exp.shift
      if code.nil? or code.first == :nil then
        result << "# do nothing"
      else
        result << process(code)
      end
    end

    result = result.join "\n"

    result = case self.context[1]
             when nil, :scope, :if, :iter, :resbody, :when, :while then
               result + "\n"
             else
               "(#{result})"
             end

    return result
  end

  def process_block_pass exp
    raise "huh?: #{exp.inspect}" if exp.size > 1

    "&#{process exp.shift}"
  end

  def process_break(exp)
    val = exp.empty? ? nil : process(exp.shift)
    # HACK "break" + (val ? " #{val}" : "")
    if val then
      "break #{val}"
    else
      "break"
    end
  end

  def process_call(exp)
    receiver_node_type = exp.first.nil? ? nil : exp.first.first
    receiver = process exp.shift

    receiver = "(#{receiver})" if
      Ruby2Ruby::ASSIGN_NODES.include? receiver_node_type

    name = exp.shift
    args = []

    # this allows us to do both old and new sexp forms:
    exp.push(*exp.pop[1..-1]) if exp.size == 1 && exp.first.first == :arglist

    @calls.push name

    in_context :arglist do
      until exp.empty? do
        arg = process exp.shift
        args << arg unless arg.empty?
      end
    end

    case name
    when *BINARY then
      "(#{receiver} #{name} #{args.join(', ')})"
    when :[] then
      receiver ||= "self"
      "#{receiver}[#{args.join(', ')}]"
    when :[]= then
      receiver ||= "self"
      rhs = args.pop
      "#{receiver}[#{args.join(', ')}] = #{rhs}"
    when :"-@" then
      "-#{receiver}"
    when :"+@" then
      "+#{receiver}"
    else
      args     = nil                    if args.empty?
      args     = "(#{args.join(', ')})" if args
      receiver = "#{receiver}."         if receiver

      "#{receiver}#{name}#{args}"
    end
  ensure
    @calls.pop
  end

  def process_case(exp)
    result = []
    expr = process exp.shift
    if expr then
      result << "case #{expr}"
    else
      result << "case"
    end
    until exp.empty?
      pt = exp.shift
      if pt and pt.first == :when
        result << "#{process(pt)}"
      else
        code = indent(process(pt))
        code = indent("# do nothing") if code =~ /^\s*$/
        result << "else\n#{code}"
      end
    end
    result << "end"
    result.join("\n")
  end

  def process_cdecl(exp)
    lhs = exp.shift
    lhs = process lhs if Sexp === lhs
    unless exp.empty? then
      rhs = process(exp.shift)
      "#{lhs} = #{rhs}"
    else
      lhs.to_s
    end
  end

  def process_class(exp)
    "class #{util_module_or_class(exp, true)}"
  end

  def process_colon2(exp)
    "#{process(exp.shift)}::#{exp.shift}"
  end

  def process_colon3(exp)
    "::#{exp.shift}"
  end

  def process_const(exp)
    exp.shift.to_s
  end

  def process_cvar(exp)
    "#{exp.shift}"
  end

  def process_cvasgn(exp)
    "#{exp.shift} = #{process(exp.shift)}"
  end

  def process_cvdecl(exp)
    "#{exp.shift} = #{process(exp.shift)}"
  end

  def process_defined(exp)
    "defined? #{process(exp.shift)}"
  end

  def process_defn(exp)
    type1 = exp[1].first
    type2 = exp[2].first rescue nil

    if type1 == :args and [:ivar, :attrset].include? type2 then
      name = exp.shift
      case type2
      when :ivar then
        exp.clear
        return "attr_reader #{name.inspect}"
      when :attrset then
        exp.clear
        return "attr_writer :#{name.to_s[0..-2]}"
      else
        raise "Unknown defn type: #{exp.inspect}"
      end
    end

    case type1
    when :scope, :args then
      name = exp.shift
      args = process(exp.shift)
      args = "" if args == "()"
      body = []
      until exp.empty? do
        body << indent(process(exp.shift))
      end
      body = body.join("\n")
      return "def #{name}#{args}\n#{body}\nend".gsub(/\n\s*\n+/, "\n")
    else
      raise "Unknown defn type: #{type1} for #{exp.inspect}"
    end
  end

  def process_defs(exp)
    lhs  = exp.shift
    var = [:self, :cvar, :dvar, :ivar, :gvar, :lvar].include? lhs.first
    name = exp.shift

    lhs = process(lhs)
    lhs = "(#{lhs})" unless var

    exp.unshift "#{lhs}.#{name}"
    process_defn(exp)
  end

  def process_dot2(exp)
    "(#{process exp.shift}..#{process exp.shift})"
  end

  def process_dot3(exp)
    "(#{process exp.shift}...#{process exp.shift})"
  end

  def process_dregx(exp)
    "/" << util_dthing(:dregx, exp) << "/"
  end

  def process_dregx_once(exp)
    process_dregx(exp) + "o"
  end

  def process_dstr(exp)
    "\"#{util_dthing(:dstr, exp)}\""
  end

  def process_dsym(exp)
    ":\"#{util_dthing(:dsym, exp)}\""
  end

  def process_dxstr(exp)
    "`#{util_dthing(:dxstr, exp)}`"
  end

  def process_ensure(exp)
    body = process exp.shift
    ens  = exp.shift
    ens  = nil if ens == s(:nil)
    ens  = process(ens) || "# do nothing"

    body.sub!(/\n\s*end\z/, '')

    return "#{body}\nensure\n#{indent ens}"
  end

  def process_evstr(exp)
    exp.empty? ? '' : process(exp.shift)
  end

  def process_false(exp)
    "false"
  end

  def process_flip2(exp)
    "#{process(exp.shift)}..#{process(exp.shift)}"
  end

  def process_flip3(exp)
    "#{process(exp.shift)}...#{process(exp.shift)}"
  end

  def process_for(exp)
    recv = process exp.shift
    iter = process exp.shift
    body = exp.empty? ? nil : process(exp.shift)

    result = ["for #{iter} in #{recv} do"]
    result << indent(body ? body : "# do nothing")
    result << "end"

    result.join("\n")
  end

  def process_gasgn(exp)
    process_iasgn(exp)
  end

  def process_gvar(exp)
    return exp.shift.to_s
  end

  def process_hash(exp)
    result = []
    until exp.empty?
      lhs = process(exp.shift)
      rhs = exp.shift
      t = rhs.first
      rhs = process rhs
      rhs = "(#{rhs})" unless [:lit, :str].include? t # TODO: verify better!

      result << "#{lhs} => #{rhs}"
    end

    case self.context[1]
    when :arglist, :argscat then
      unless result.empty? then
        # HACK - this will break w/ 2 hashes as args
        if BINARY.include? @calls.last then
          return "{ #{result.join(', ')} }"
        else
          return "#{result.join(', ')}"
        end
      else
        return "{}"
      end
    else
      return "{ #{result.join(', ')} }"
    end
  end

  def process_iasgn(exp)
    lhs = exp.shift
    if exp.empty? then # part of an masgn
      lhs.to_s
    else
      "#{lhs} = #{process exp.shift}"
    end
  end

  def process_if(exp)
    expand = Ruby2Ruby::ASSIGN_NODES.include? exp.first.first
    c = process exp.shift
    t = process exp.shift
    f = process exp.shift

    c = "(#{c.chomp})" if c =~ /\n/

    if t then
      unless expand then
        if f then
          r = "#{c} ? (#{t}) : (#{f})"
          r = nil if r =~ /return/ # HACK - need contextual awareness or something
        else
          r = "#{t} if #{c}"
        end
        return r if r and (@indent+r).size < LINE_LENGTH and r !~ /\n/
      end

      r = "if #{c} then\n#{indent(t)}\n"
      r << "else\n#{indent(f)}\n" if f
      r << "end"

      r
    else
      unless expand then
        r = "#{f} unless #{c}"
        return r if (@indent+r).size < LINE_LENGTH and r !~ /\n/
      end
      "unless #{c} then\n#{indent(f)}\nend"
    end
  end

  def process_iter(exp)
    iter = process exp.shift
    args = exp.shift
    args = (args == 0) ? '' : process(args)
    body = exp.empty? ? nil : process(exp.shift)

    b, e = if iter == "END" then
             [ "{", "}" ]
           else
             [ "do", "end" ]
           end

    iter.sub!(/\(\)$/, '')

    # REFACTOR: ugh
    result = []
    result << "#{iter} {"
    result << " |#{args}|" if args
    if body then
      result << " #{body.strip} "
    else
      result << ' '
    end
    result << "}"
    result = result.join
    return result if result !~ /\n/ and result.size < LINE_LENGTH

    result = []
    result << "#{iter} #{b}"
    result << " |#{args}|" if args
    result << "\n"
    if body then
      result << indent(body.strip)
      result << "\n"
    end
    result << e
    result.join
  end

  def process_ivar(exp)
    exp.shift.to_s
  end

  def process_lasgn(exp)
    s = "#{exp.shift}"
    s += " = #{process exp.shift}" unless exp.empty?
    s
  end

  def process_lit(exp)
    obj = exp.shift
    case obj
    when Range then
      "(#{obj.inspect})"
    else
      obj.inspect
    end
  end

  def process_lvar(exp)
    exp.shift.to_s
  end

  def splat(sym)
    :"*#{sym}"
  end

  def process_masgn(exp)
    lhs = exp.shift
    rhs = exp.empty? ? nil : exp.shift

    case lhs.first
    when :array then
      lhs.shift
      lhs = lhs.map do |l|
        case l.first
        when :masgn then
          "(#{process(l)})"
        else
          process(l)
        end
      end
    when :lasgn then
      lhs = [ splat(lhs.last) ]
    when :splat then
      lhs = [ :"*" ]
    else
      raise "no clue: #{lhs.inspect}"
    end

    if context[1] == :iter and rhs then
      lhs << splat(rhs[1])
      rhs = nil
    end

    unless rhs.nil? then
      t = rhs.first
      rhs = process rhs
      rhs = rhs[1..-2] if t == :array # FIX: bad? I dunno
      return "#{lhs.join(", ")} = #{rhs}"
    else
      return lhs.join(", ")
    end
  end

  def process_match(exp)
    "#{process(exp.shift)}"
  end

  def process_match2(exp)
    lhs = process(exp.shift)
    rhs = process(exp.shift)
    "#{lhs} =~ #{rhs}"
  end

  def process_match3(exp)
    rhs = process(exp.shift)
    lhs = process(exp.shift)
    "#{lhs} =~ #{rhs}"
  end

  def process_module(exp)
    "module #{util_module_or_class(exp)}"
  end

  def process_next(exp)
    val = exp.empty? ? nil : process(exp.shift)
    if val then
      "next #{val}"
    else
      "next"
    end
  end

  def process_nil(exp)
    "nil"
  end

  def process_not(exp)
    "(not #{process exp.shift})"
  end

  def process_nth_ref(exp)
    "$#{exp.shift}"
  end

  def process_op_asgn1(exp)
    # [[:lvar, :b], [:arglist, [:lit, 1]], :"||", [:lit, 10]]
    lhs = process(exp.shift)
    index = process(exp.shift)
    msg = exp.shift
    rhs = process(exp.shift)

    "#{lhs}[#{index}] #{msg}= #{rhs}"
  end

  def process_op_asgn2(exp)
    # [[:lvar, :c], :var=, :"||", [:lit, 20]]
    lhs = process(exp.shift)
    index = exp.shift.to_s[0..-2]
    msg = exp.shift

    rhs = process(exp.shift)

    "#{lhs}.#{index} #{msg}= #{rhs}"
  end

  def process_op_asgn_and(exp)
    # a &&= 1
    # [[:lvar, :a], [:lasgn, :a, [:lit, 1]]]
    exp.shift
    process(exp.shift).sub(/\=/, '&&=')
  end

  def process_op_asgn_or(exp)
    # a ||= 1
    # [[:lvar, :a], [:lasgn, :a, [:lit, 1]]]
    exp.shift
    process(exp.shift).sub(/\=/, '||=')
  end

  def process_or(exp)
    "(#{process exp.shift} or #{process exp.shift})"
  end

  def process_postexe(exp)
    "END"
  end

  def process_redo(exp)
    "redo"
  end

  def process_resbody exp
    args = exp.shift
    body = process(exp.shift) || "# do nothing"

    name =   args.lasgn true
    name ||= args.iasgn true
    args = process(args)[1..-2]
    args = " #{args}" unless args.empty?
    args += " => #{name[1]}" if name

    "rescue#{args}\n#{indent body}"
  end

  def process_rescue exp
    body = process(exp.shift) unless exp.first.first == :resbody
    els  = process(exp.pop)   unless exp.last.first  == :resbody

    body ||= "# do nothing"
    simple = exp.size == 1

    resbodies = []
    until exp.empty? do
      resbody = exp.shift
      simple &&= resbody[1] == s(:array) && resbody[2] != nil
      resbodies << process(resbody)
    end

    if els then
      "#{indent body}\n#{resbodies.join("\n")}\nelse\n#{indent els}"
    elsif simple then
      resbody = resbodies.first.sub(/\n\s*/, ' ')
      "#{body} #{resbody}"
    else
      "#{indent body}\n#{resbodies.join("\n")}"
    end
  end

  def process_retry(exp)
    "retry"
  end

  def process_return(exp)
    # HACK return "return" + (exp.empty? ? "" : " #{process exp.shift}")

    if exp.empty? then
      return "return"
    else
      return "return #{process exp.shift}"
    end
  end

  def process_sclass(exp)
    "class << #{process(exp.shift)}\n#{indent(process(exp.shift))}\nend"
  end

  def process_scope(exp)
    exp.empty? ? "" : process(exp.shift)
  end

  def process_self(exp)
    "self"
  end

  def process_splat(exp)
    if exp.empty? then
      "*"
    else
      "*#{process(exp.shift)}"
    end
  end

  def process_str(exp)
    return exp.shift.dump
  end

  def process_super(exp)
    args = []
    until exp.empty? do
      args << process(exp.shift)
    end

    "super(#{args.join(', ')})"
  end

  def process_svalue(exp)
    code = []
    until exp.empty? do
      code << process(exp.shift)
    end
    code.join(", ")
  end

  def process_to_ary(exp)
    process(exp.shift)
  end

  def process_true(exp)
    "true"
  end

  def process_undef(exp)
    "undef #{process(exp.shift)}"
  end

  def process_until(exp)
    cond_loop(exp, 'until')
  end

  def process_valias(exp)
    "alias #{exp.shift} #{exp.shift}"
  end

  def process_when(exp)
    src = []

    if self.context[1] == :array then # ugh. matz! why not an argscat?!?
      val = process(exp.shift)
      exp.shift # empty body
      return "*#{val}"
    end

    until exp.empty?
      cond = process(exp.shift).to_s[1..-2]
      code = indent(process(exp.shift))
      code = indent "# do nothing" if code =~ /\A\s*\Z/
      src << "when #{cond} then\n#{code.chomp}"
    end

    src.join("\n")
  end

  def process_while(exp)
    cond_loop(exp, 'while')
  end

  def process_xstr(exp)
    "`#{process_str(exp)[1..-2]}`"
  end

  def process_yield(exp)
    args = []
    until exp.empty? do
      args << process(exp.shift)
    end

    unless args.empty? then
      "yield(#{args.join(', ')})"
    else
      "yield"
    end
  end

  def process_zsuper(exp)
    "super"
  end

  def cond_loop(exp, name)
    cond = process(exp.shift)
    body = process(exp.shift)
    head_controlled = exp.shift

    body = indent(body).chomp if body

    code = []
    if head_controlled then
      code << "#{name} #{cond} do"
      code << body if body
      code << "end"
    else
      code << "begin"
      code << body if body
      code << "end #{name} #{cond}"
    end
    code.join("\n")
  end

  ############################################################
  # Rewriters:

  def rewrite_attrasgn exp
    if context.first(2) == [:array, :masgn] then
      exp[0] = :call
      exp[2] = exp[2].to_s.sub(/=$/, '').to_sym
    end

    exp
  end

  def rewrite_ensure exp
    exp = s(:begin, exp) unless context.first == :begin
    exp
  end

  def rewrite_resbody exp
    raise "no exception list in #{exp.inspect}" unless exp.size > 2 && exp[1]
    raise exp[1].inspect if exp[1][0] != :array
    # for now, do nothing, just check and freak if we see an errant structure
    exp
  end

  def rewrite_rescue exp
    complex = false
    complex ||= exp.size > 3
    complex ||= exp.block
    complex ||= exp.find_nodes(:resbody).any? { |n| n[1] != s(:array) }
    complex ||= exp.find_nodes(:resbody).any? { |n| n.last.nil? }

    handled = context.first == :ensure

    exp = s(:begin, exp) if complex unless handled

    exp
  end

  def rewrite_svalue(exp)
    case exp.last.first
    when :array
      s(:svalue, *exp[1][1..-1])
    when :splat
      exp
    else
      raise "huh: #{exp.inspect}"
    end
  end

  ############################################################
  # Utility Methods:

  def dthing_escape type, lit
    lit = lit.gsub(/\n/, '\n')
    case type
    when :dregx then
      lit.gsub(/(\A|[^\\])\//, '\1\/')
    when :dstr, :dsym then
      lit.gsub(/"/, '\"')
    when :dxstr then
      lit.gsub(/`/, '\`')
    else
      raise "unsupported type #{type.inspect}"
    end
  end

  def util_dthing(type, exp)
    s = []

    # first item in sexp is a string literal
    s << dthing_escape(type, exp.shift)

    until exp.empty?
      pt = exp.shift
      case pt
      when Sexp then
        case pt.first
        when :str then
          s << dthing_escape(type, pt.last)
        when :evstr then
          s << '#{' << process(pt) << '}' # do not use interpolation here
        else
          raise "unknown type: #{pt.inspect}"
        end
      else
        # HACK: raise "huh?: #{pt.inspect}" -- hitting # constants in regexps
        # do nothing for now
      end
    end

    s.join
  end

  def util_module_or_class(exp, is_class=false)
    result = []

    name = exp.shift
    name = process name if Sexp === name

    result << name

    if is_class then
      superk = process(exp.shift)
      result << " < #{superk}" if superk
    end

    result << "\n"

    body = []
    begin
      code = process(exp.shift)
      body << code.chomp unless code.nil? or code.chomp.empty?
    end until exp.empty?

    unless body.empty? then
      body = indent(body.join("\n\n")) + "\n"
    else
      body = ""
    end
    result << body
    result << "end"

    result.join
  end

  def indent(s)
    s.to_s.split(/\n/).map{|line| @indent + line}.join("\n")
  end
end
