module KeyPairComputeResource
  extend ActiveSupport::Concern

  included do
    prepend KeyPairCapabilities
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy
    after_create :setup_key_pair
    after_destroy :destroy_key_pair
    delegate :key_pairs, :to => :client
  end

  def get_compute_key_pairs
    return [] unless capabilities.include?(:key_pair)
    active_key = key_pair
    return [] if key_pairs.nil? || active_key.nil?
    key_pairs.map do |key|
      ComputeResourceKeyPair.new(key.name, key.fingerprint, active_key.name, active_key.id)
    end
  end

  def recreate
    destroy_key_pair
    setup_key_pair
  end

  def delete_key_pair(key_pair_name)
    raise Foreman::Exception.new(N_('Cannot delete existing key pair %s') % key_pair_name) if KeyPair.find_by_name(key_pair_name)
    delete_key_from_resource(key_pair_name)
  end

  private

  def setup_key_pair(cr_id = id)
    key = client.key_pairs.create :name => "foreman-#{id}#{Foreman.uuid}"
    KeyPair.create! :name => key.name, :compute_resource_id => cr_id, :secret => key.private_key
  rescue => e
    Foreman::Logging.exception("Failed to generate key pair", e)
    destroy_key_pair
    raise
  end

  def destroy_key_pair
    return unless key_pair
    delete_key_from_resource(key_pair.name)
    key_pair.destroy!
  end

  def delete_key_from_resource(key_pair_name)
    logger.info "removing #{provider_friendly_name}: #{name} key #{key_pair_name}"
    key = client.key_pairs.get(key_pair_name)
    key.nil? || key.destroy
  rescue => e
    logger.warn "failed to delete key pair from #{provider_friendly_name}: #{name}, you might need to cleanup manually : #{e}"
  end
end
