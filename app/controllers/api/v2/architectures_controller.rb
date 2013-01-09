module Api
  module V2
    class ArchitecturesController < V1::ArchitecturesController
      include Api::Version2
    end
  end
end
