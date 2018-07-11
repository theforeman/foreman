module Foreman
  module Renderer
    module Scope
      class Partition < Foreman::Renderer::Scope::Base
        include Foreman::Renderer::Scope::Macros::HostTemplate
      end
    end
  end
end
