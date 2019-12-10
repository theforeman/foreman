class UserMenusController < Api::V2::BaseController
  def menu
    render :json => UserMenu.new.generate
  end
end
