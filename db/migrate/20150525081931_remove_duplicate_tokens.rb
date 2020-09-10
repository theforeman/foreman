class RemoveDuplicateTokens < ActiveRecord::Migration[4.2]
  def up
    # only managed hosts should have tokens
    Token.where(:id => Token.joins("left outer join hosts on hosts.id = tokens.host_id").
                             where("hosts.type != 'Host::Managed'").pluck('tokens.id')).delete_all

    # deleting duplicate tokens
    hosts_with_duplicate_tokens = Token.having('count(*) > 1').group(:host_id).pluck('host_id')
    existing_tokens = Host.where(:id => hosts_with_duplicate_tokens).map(&:token).compact
    if existing_tokens.empty?
      Token.where(:id => Token.where(:host_id => hosts_with_duplicate_tokens).pluck('tokens.id')).delete_all
    else
      Token.where(:id => Token.where('host_id in (?) and id not in (?)', hosts_with_duplicate_tokens, existing_tokens).pluck('tokens.id')).delete_all
    end

    remove_foreign_key :tokens, :column => :host_id if foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
    remove_index :tokens, :host_id if index_exists? :tokens, :host_id
    add_index :tokens, :host_id, :unique => true
    add_foreign_key :tokens, :hosts, :name => "tokens_host_id_fk" unless foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
  end

  def down
    remove_foreign_key :tokens, :column => :host_id if foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
    remove_index :tokens, :host_id if index_exists? :tokens, :host_id
    add_index :tokens, :host_id
    add_foreign_key :tokens, :hosts, :name => "tokens_host_id_fk" unless foreign_key_exists?(:tokens, { :name => "tokens_host_id_fk" })
  end
end
