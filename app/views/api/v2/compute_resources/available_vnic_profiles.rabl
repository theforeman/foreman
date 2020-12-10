collection @available_vnic_profiles

attribute :name, :id

node :network do |vnic_profile|
  vnic_profile.network&.id
end
