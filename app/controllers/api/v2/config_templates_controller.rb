module Api
  module V2
    class ConfigTemplatesController < V1::ConfigTemplatesController
      include Api::Version2

      before_filter :process_operatingsystems, :only => [:create, :update]

      def process_operatingsystems
        return unless (ct = params[:config_template]) and (operatingsystems = ct.delete(:operatingsystems))
        ct[:operatingsystem_ids] = operatingsystems.collect {|os| os[:id]}
      end
    end
  end
end
