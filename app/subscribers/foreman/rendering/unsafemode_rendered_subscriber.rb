module Foreman
  module Rendering
    class UnsafemodeRenderedSubscriber < Rendering::BaseSubscriber
      private

      def update_combination
        combination.update!(unsafemode_status: HostStatus::RenderingStatusCombination::OK)
      end

      def update_warnings
        combinations.where(unsafemode_status: HostStatus::RenderingStatusCombination::WARN)
                    .update_all(unsafemode_status: HostStatus::RenderingStatusCombination::OK)
      end
    end
  end
end
