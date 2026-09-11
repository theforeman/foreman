module Foreman
  module Controller
    module TopbarSweeper
      extend ActiveSupport::Concern

      included do
        around_action :set_topbar_sweeper_controller
      end

      def set_topbar_sweeper_controller
        ::TopbarSweeper.controller = self
        yield
      ensure
        ::TopbarSweeper.controller = nil
      end
    end
  end
end
