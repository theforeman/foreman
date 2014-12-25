module FogExtensions
  module Openstack
    module Server
      module BlockDeviceMapping

        class Block
          extend ActiveSupport::Concern

          attr_accessor :device_name, :delete_on_termination, :volume_id
          attr_accessor :_destroy

          # These methods are used to trick form_builder into thinking this is
          # an ActiveRecord model so that the form is showed properly.
          def persisted?; end
          def id; end
        end

      end
    end
  end
end
