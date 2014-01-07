module Foreman::Controller::UsersMixin
  extend ActiveSupport::Concern

  included do
    before_filter :set_admin_on_creation, :only => :create
    before_filter :clear_params_on_update, :only => :update
  end

  protected
  def set_admin_on_creation
    admin = params[:user].delete :admin
    @user = User.new(params[:user]) { |u| u.admin = admin }
  end

  def clear_params_on_update
    find_resource
    if params[:user]
      @admin = params[:user].has_key?(:admin) ? params[:user].delete(:admin) : nil
      # Remove keys for restricted variables when the user is editing their own account
      if editing_self?
        params[:user].slice!(:password_confirmation, :password, :mail, :firstname, :lastname, :locale)

        # Remove locale from the session when set to "Browser Locale" and editing self
        session.delete(:locale) if params[:user][:locale].try(:empty?)
      end
    end
  end

  def editing_self?
    @editing_self ||= User.current.editing_self?(params.slice(:controller, :action, :id))
  end

  def update_sub_hostgroups_owners
    return if params[:user]['hostgroup_ids'].empty?
    hostgroup_ids = params[:user]['hostgroup_ids'].reject(&:empty?).map(&:to_i)
    return if hostgroup_ids.empty?

    sub_hg = Hostgroup.where(:id => hostgroup_ids).map(&:subtree).flatten.reject { |hg| hg.user_ids.include?(@user.id) }
    sub_hg.each { |hg| hg.users << @user }
  end
end
