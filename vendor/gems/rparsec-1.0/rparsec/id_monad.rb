module RParsec
  
class IdMonad
  def value v
    v
  end
  
  def bind prev
    yield prev
  end
  
  def mplus a, b
    a
  end
end

end # module