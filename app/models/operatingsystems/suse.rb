class Suse < Operatingsystem
  PXEFILES = {:kernel => "linux", :initrd => "initrd"}

  class << self
    delegate :model_name, :to => :superclass
  end

  def pxe_type
    "yast"
  end

  def pxedir
    "boot/$arch/loader"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def display_family
    "SUSE"
  end

  def self.shorten_description(description)
    return "" if description.blank?
    s=description
    s.gsub!('SUSE Linux Enterprise Server','SLES')
    s.gsub!(/\(.+?\)/,'')
    s.squeeze! " "
    s.strip!
    s.blank? ? description : s
  end
end
