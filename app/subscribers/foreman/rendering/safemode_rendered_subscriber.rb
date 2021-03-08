module Foreman
  module Rendering
    class SafemodeRenderedSubscriber < Rendering::BaseSubscriber
      private

      def update_combination
        combination.update!(safemode_status: HostStatus::RenderingStatusCombination::OK)
      end

      def update_warnings
        combinations.where(safemode_status: HostStatus::RenderingStatusCombination::WARN)
                    .update_all(safemode_status: HostStatus::RenderingStatusCombination::OK)
      end
    end
  end
end
