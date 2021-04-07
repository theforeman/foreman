module FogExtensions
  module AWS
    module IAM
      module InstanceProfile
        extend ActiveSupport::Concern
        def to_label
          name.to_s
        end
      end
    end
  end
end
