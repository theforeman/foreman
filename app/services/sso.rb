module SSO
  METHODS = [Apache, SignoBasic, Basic, Oauth, Signo]

  def self.get_available(controller)
    all_methods = all.map { |method| method.new(controller) }
    all_methods.select(&:available?).first
  end

  def self.all
    METHODS
  end

end
