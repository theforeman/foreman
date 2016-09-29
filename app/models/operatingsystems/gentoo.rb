class Gentoo < Operatingsystem
  PXEFILES = {}

  class << self
    delegate :model_name, :to => :superclass
  end

  def mediumpath(host)
  end

  def pxe_type
  end

  def pxedir
  end

  def url_for_boot(file)
  end

  def display_family
    "Gentoo"
  end
end
