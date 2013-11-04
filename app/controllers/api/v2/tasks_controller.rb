module Api
  module V2
    class TasksController < BaseController
      before_filter :find_tasks

      api :GET, '/orchestration/:id/tasks/', 'List all tasks for a given orchestration event'

      def index
        # @tasks is already in JSON format
        render :text => @tasks
      end

      private

      def find_tasks
        return not_found unless Foreman.is_uuid?((id = params[:id]))
        @tasks = Rails.cache.fetch(id)
        not_found if @tasks.blank?
      end

    end
  end
end
