module Api
  module V2
    class HostgroupsController < V1::HostgroupsController
      include Api::Version2
    end
  end
end
