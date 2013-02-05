class TasksController < ApplicationController
  skip_before_filter :session_expiry, :update_activity_time, :set_taxonomy, :only => [:show]

  def show
    id = params[:id]
    queue = Rails.cache.fetch(id)
    respond_to do |format|
      format.html {
        @tasks = queue.nil? ? [] : JSON(queue)
        return render :partial => 'list' if ajax?
      }
      format.json { render :json => queue }
    end
  end

end
