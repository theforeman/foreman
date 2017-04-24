object @key_pair

attributes :name, :active
attribute :used_elsewhere => :is_used
attribute(:key_pair_id, :if => lambda { |key| key.key_pair_id})
