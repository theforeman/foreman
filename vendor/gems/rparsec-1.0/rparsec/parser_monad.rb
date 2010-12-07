module RParsec
  
class ParserMonad
  def fail msg
    FailureParser.new(msg)
  end
  
  def value v
    return Nil if v.nil?
    ValueParser.new(v);
  end
  
  def bind(v, &proc)
    return v unless proc
    BoundParser.new(v, proc);
  end
  
  def mplus(p1, p2)
    PlusParser.new([p1,p2]);
  end
end

end # module