class NoticesController < ApplicationController
  skip_before_filter :authorize, :only => :destroy

  def destroy
    @notice = Notice.find(params[:id])
    @notice.destroy_notice
    redirect_to :back
  end
end
