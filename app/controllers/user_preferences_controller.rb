class UserPreferencesController < Api::V2::BaseController
  include Foreman::Controller::Parameters::UserPreference

  def index
    return render :json => { enabled: false } unless Setting[:tours]

    preferences = Hash[UserPreference.search_for(params[:search]).map { |pref| [pref.name, pref.value]}]
    render :json => preferences
  end

  def create
    @user_preference = User.current.user_preferences.new(user_preference_params)
    process_response @user_preference.save!
  end
end
