module Types
  module Networks
    class Vmware < Types::BaseObject
      description 'A Network on a VMWare Compute Resource'

      field :id, ID, null: false
      field :name, String, null: false
      field :virtualswitch, String, null: true
      field :datacenter, String, null: false
      field :accessible, Boolean, null: true
      field :vlanid, Integer, null: true
    end
  end
end
