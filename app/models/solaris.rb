class Solaris < Operatingsystem

  # Override the class representation, as this breaks many rails helpers
  def class
    Operatingsystem
  end

end
