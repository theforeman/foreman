module RParsec

#
# Internal utility functions for string manipulations.
#
module StringUtils
  #
  # Does _str_ starts with the _sub_ string?
  # 
  def self.starts_with? str, sub
    return true if sub.nil?
    len = sub.length
    return false if len > str.length
    for i in (0...len)
      return false if str[i] != sub[i]
    end
    true
  end
end

#
# Helpers for defining ctor.
#
module DefHelper
  def def_ctor(*vars)
    define_method(:initialize) do |*params|
      vars.each_with_index do |var, i|
        instance_variable_set("@"+var.to_s, params[i])
      end
    end
  end

  def def_readable(*vars)
    attr_reader(*vars)
    def_ctor(*vars)
  end

  def def_mutable(*vars)
    attr_accessor(*vars)
    def_ctor(*vars)
  end
end

#
# To type check method parameters.
# 
module TypeChecker
  private
  
  def nth n
    th = case n when 0 then 'st' when 1 then 'nd' else 'th' end
    "#{n+1}#{th}"
  end
  
  public
  
  def check_arg_type expected, obj, mtd, n=0
    unless obj.kind_of? expected
      raise ArgumentError,
        "#{obj.class} assigned to #{expected} for the #{nth n} argument of #{mtd}."
    end
  end
  
  def check_arg_array_type elem_type, arg, mtd, n=0
    check_arg_type Array, arg, mtd, n
    arg.each_with_index do |x, i|
      unless x.kind_of? elem_type
        raise ArgumentError,
          "#{x.class} assigned to #{elem_type} for the #{nth i} element of the #{nth n} argument of #{mtd}."
      end
    end
  end
  
  def check_vararg_type expected, args, mtd, n = 0
    (n...args.length).each do |i|
      check_arg_type expected, args[i], mtd, i
    end
  end
  
  extend self
end

#
# To add declarative signature support.
# 
module Signature
  # Signatures = {}
  def def_sig sym, *types
    types.each_with_index do |t,i|
      unless t.kind_of? Class
        TypeChecker.check_arg_type Class, t, :def_sig, i unless t.kind_of? Array
        TypeChecker.check_arg_type Class, t, :def_sig, i unless t.length <= 1
        TypeChecker.check_arg_array_type Class, t, :def_sig, i
      end
    end
    # Signatures[sym] = types
    __intercept_method_to_check_param_types__(sym, types)
  end
  
  private
  
  def __intercept_method_to_check_param_types__(sym, types)
    mtd = instance_method(sym)
    helper = "_#{sym}_param_types_checked_helper".to_sym
    define_method(helper) do |*params|
      star_type, star_ind = nil, nil
      types.each_with_index do |t, i|
        t = star_type unless star_type.nil?
        arg = params[i]
        if t.kind_of? Class
          TypeChecker.check_arg_type t, arg, sym, i
        elsif t.empty?
          TypeChecker.check_arg_type Array, arg, sym, i
        else
          star_type, star_ind = t[0], i
          break
        end
      end
      TypeChecker.check_vararg_type star_type, params, sym, star_ind unless star_ind.nil?
      mtd.bind(self)
    end
    module_eval """
    def #{sym}(*params, &block)
      #{helper}(*params).call(*params, &block)
    end
    """
  end
end

end # module