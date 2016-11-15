class ComputeResourceKeyPair
  attr_reader :name, :fingerprint, :active, :key_pair_id, :used_elsewhere

  def initialize(keypair_name, keypair_fingerprint, active_key_name, active_key_id)
    @name = keypair_name
    @fingerprint = keypair_fingerprint
    @active = is_active?(active_key_name)
    @key_pair_id = active_key_id if @active
    @used_elsewhere = used_elsewhere?
  end

  private

  def is_active?(active_key_name)
    @name == active_key_name
  end

  def used_elsewhere?
    !@active && KeyPair.exists?(name: @name)
  end
end
