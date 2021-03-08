module Foreman
  module Rendering
    class SafemodeErrorSubscriber < Rendering::BaseSubscriber
      private

      def update_combination
        combination.update!(safemode_status: HostStatus::RenderingStatusCombination::ERROR)
      end

      def update_warnings
        combinations.where(safemode_status: HostStatus::RenderingStatusCombination::OK)
                    .update_all(safemode_status: HostStatus::RenderingStatusCombination::WARN)
      end
    end
  end
end
