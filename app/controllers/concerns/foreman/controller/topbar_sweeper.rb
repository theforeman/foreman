module Foreman
  module Controller
    module TopbarSweeper
      extend ActiveSupport::Concern

      included do
        around_action :set_topbar_sweeper_controller
      end

      def set_topbar_sweeper_controller
        ::TopbarSweeper.instance.controller = self
        yield
      ensure
        ::TopbarSweeper.instance.controller = nil
      end
    end
  end
end
