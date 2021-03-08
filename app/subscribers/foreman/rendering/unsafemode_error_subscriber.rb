module Foreman
  module Rendering
    class UnsafemodeErrorSubscriber < Rendering::BaseSubscriber
      private

      def update_combination
        combination.update!(unsafemode_status: HostStatus::RenderingStatusCombination::ERROR)
      end

      def update_warnings
        combinations.where(unsafemode_status: HostStatus::RenderingStatusCombination::OK)
                    .update_all(unsafemode_status: HostStatus::RenderingStatusCombination::WARN)
      end
    end
  end
end
