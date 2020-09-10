require "time"

class SmartProxies::PuppetCACertificate
  attr_reader :name, :state, :fingerprint, :valid_from, :expires_at, :status_object

  def initialize(opts)
    @name, @state, @fingerprint, @valid_from, @expires_at, @status_object = opts.flatten
    @valid_from = Time.parse(@valid_from).utc if @valid_from.present?
    @expires_at = Time.parse(@expires_at).utc if @expires_at.present?
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
    name <=> other.name
  end
end
