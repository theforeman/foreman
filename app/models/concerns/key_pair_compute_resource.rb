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

  def delete_key_from_resource(remote_key_pair = key_pair.name)
    logger.info "removing key from compute resource #{name} "\
                "(#{provider_friendly_name}): #{remote_key_pair}"
    client.key_pairs.get(remote_key_pair).try(:destroy)
  rescue => e
    Foreman::Logging.exception(
      "Failed to delete key pair from #{provider_friendly_name}: #{name}, you "\
      "might need to cleanup manually: #{e}",
      e,
      :level => :warn
    )
  end

  private

  def setup_key_pair
    key = client.key_pairs.create :name => "foreman-#{id}#{Foreman.uuid}"
    KeyPair.create! :name => key.name, :compute_resource_id => id, :secret => key.private_key
  rescue => e
    Foreman::Logging.exception("Failed to generate key pair", e)
    destroy_key_pair
    raise
  end

  def destroy_key_pair
    return unless key_pair.present?
    delete_key_from_resource
    # If the key pair could not be removed, it will be logged.
    # Returning 'true' allows this method to not halt the deletion
    # of the Compute Resource even if the key pair could not be
    # deleted for some reason (permissions, not found, etc...)
    true
  end
end
