class TasksController < ApplicationController
  skip_before_action :session_expiry, :update_activity_time, :set_taxonomy, :only => [:show]
  before_action :ajax_request

  def show
    id     = params[:id]
    queue  = Rails.cache.fetch(id)
    @tasks = queue.nil? ? [] : JSON(queue)
    render :partial => 'list'
  end
end
