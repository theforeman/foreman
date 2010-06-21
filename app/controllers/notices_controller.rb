class NoticesController < ApplicationController
  def destroy
    @notice = Notice.find(params[:id])
    if @notice.global
      @notice.destroy
    else
      @notice.users.delete(current_user)
      @notice.destroy unless @notice.users.any?
    end
    redirect_to :back
  end
end
