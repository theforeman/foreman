class ChangeComputeResourcePasswordToText < ActiveRecord::Migration[4.2]
  def up
    # encrypted passwords may be over 255 characters, so column is changed to text
    change_column :compute_resources, :password, :text
    say "You need to run rake security:generate_encryption_key to generate an ENCRYPTION_KEY."
    say "Then, you may run rake db:compute_resources:encrypt to encrypt the passwords for Compute Resources."
    say "Conversely, you may run rake db:compute_resources:decrypt to decrypt the passwords for Compute Resources."
  end

  def down
    change_column :compute_resources, :password, :string
    say "You may first need to run rake db:compute_resources:decrypt if there is an error value is greater than 255 characters"
  end
end
