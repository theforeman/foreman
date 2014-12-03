class Gentoo < Operatingsystem

  PXEFILES = {}

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

  def self.model_name
    superclass.model_name
  end

end
