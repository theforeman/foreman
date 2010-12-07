module RParsec
  
#
# module for Monad
#
module Monad
  attr_reader :this
  
  #
  # To initialize with a monad implementation and an object that obeys the monad law.
  #
  def initMonad(m, v)
    raise ArgumentError, 'monad cannot be nil' if m.nil?
    @monad = m;
    @this = v;
  end
  
  #
  # To create a value based on the monad impl.
  # 
  def value v
    @monad.value v
  end
  
  #
  # Run the _bind_ operation on the encapsulated object following the monad law.
  # 
  def bind(&binder)
    @monad.bind(@this, &binder)
  end
  
  #
  # Run the _seq_ operation on the encapsulated object following the monad law.
  # If _seq_ is not defined by the monad impl, use _bind_ to implement.
  # 
  def seq(other)
    if @monad.respond_to? :seq
      @monad.seq(other)
    else bind {|x|other}
    end
  end
  
  #
  # Run the _map_ operation on the encapsulated object following the monad law.
  # _bind_ is used to implement.
  # 
  def map(&mapper)
    bind do |v|
      result = mapper.call v;
      value(result);
    end
  end
  
  #
  # Run the _plus_ operation on the encapsulated object following the MonadPlus law.
  # 
  def plus other
    @monad.mplus(@this, other.this)
  end
end

end # module