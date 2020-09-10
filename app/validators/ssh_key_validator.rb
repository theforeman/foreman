class SshKeyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && !valid_ssh_public_key?(value)
      record.errors[attribute] << _('is not a valid public ssh key')
    end
  end

  private

  def valid_ssh_public_key?(key)
    SSHKey.valid_ssh_public_key?(key)
  rescue SSHKey::PublicKeyError => exception
    Foreman::Logging.exception("Invalid SSH public key", exception)
    false
  end
end
