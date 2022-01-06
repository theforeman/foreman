module FogExtensions
  module Vsphere
    module Folder
      extend ActiveSupport::Concern
      def to_label
        path.slice((path.index(datacenter) + datacenter.length + 1)..-1)&.gsub('/', ' / ')
      end
    end
  end
end
