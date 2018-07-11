module Foreman
  module Renderer
    module Scope
      class Provisioning < Foreman::Renderer::Scope::Base
        include Foreman::Renderer::Scope::Macros::HostTemplate
        include Foreman::Renderer::Scope::Variables::Base
      end
    end
  end
end
