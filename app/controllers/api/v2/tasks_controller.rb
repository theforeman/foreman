module Api
  module V2
    class TasksController < BaseController
      layout false

      api :GET, "/orchestration/:id/tasks/", N_("List all tasks for a given orchestration event")

      def index
        return not_found unless Foreman.is_uuid?((id = params[:id]))
        # cache.fetch returns in JSON format, so convert @tasks back to hash
        @tasks = JSON.parse(Rails.cache.fetch(id))
        not_found if @tasks.blank?
        render :json => { root_node_name => @tasks }
      end
    end
  end
end
