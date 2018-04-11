class Gentoo < Operatingsystem
  PXEFILES = {}.freeze

  def mediumpath(host)
  end

  def url_for_boot(file)
  end

  def display_family
    "Gentoo"
  end
end
