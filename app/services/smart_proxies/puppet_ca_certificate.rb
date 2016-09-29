require "time"

class SmartProxies::PuppetCACertificate
  attr_reader :name, :state, :fingerprint, :valid_from, :expires_at, :status_object

  def initialize(opts)
    @name, @state, @fingerprint, @valid_from, @expires_at, @status_object = opts.flatten
    @valid_from = Time.parse(@valid_from).utc unless @valid_from.blank?
    @expires_at = Time.parse(@expires_at).utc unless @expires_at.blank?
  end

  def sign
    raise ::Foreman::Exception.new(N_("unable to sign a non pending certificate")) unless state == "pending"
    status_object.sign(name)
  end

  def destroy
    status_object.destroy(name)
  end

  def to_s
    name
  end

  def <=>(other)
    self.name <=> other.name
  end
end
