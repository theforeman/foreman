class Gentoo < Operatingsystem
  PXEFILES = {}

  def mediumpath(_medium_provider)
  end

  def url_for_boot(_medium_provider, file)
  end

  def display_family
    "Gentoo"
  end
end
