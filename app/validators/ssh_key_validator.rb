class SshKeyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && !valid_ssh_public_key?(value)
      record.errors.add(attribute, _('is not a valid public ssh key'))
    end
  end

  private

  def valid_ssh_public_key?(key)
    Foreman::Provision::SshKey.new(key).valid?
  rescue Foreman::Provision::SshKey::Error => exception
    Foreman::Logging.exception("Invalid SSH public key", exception)
    false
  end
end
