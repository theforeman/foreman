module Foreman::Controller::UsersMixin
  extend ActiveSupport::Concern
  include StrongParametersHelper

  included do
    before_filter :set_admin_on_creation, :only => :create
    before_filter :clear_params_on_update, :update_admin_flag, :only => :update
  end

  def resource_scope(options = {})
    super(options).except_hidden
  end

  protected

  def user_params
    params.require(:user).permit(*permitted_user_attributes)
  end

  def set_admin_on_creation
    admin = params[:user].delete(:admin)
    @user = User.new(user_params) { |u| u.admin = admin unless admin.nil? }
  end

  def clear_params_on_update
    if params[:user]
      @admin = params[:user].has_key?(:admin) ? params[:user].delete(:admin) : nil
      # Remove keys for restricted variables when the user is editing their own account
      if editing_self?
        params[:user].slice!(:password_confirmation,
                             :password,
                             :mail,
                             :firstname,
                             :lastname,
                             :locale,
                             :timezone,
                             :default_organization_id,
                             :default_location_id,
                             :user_mail_notifications_attributes,
                             :mail_enabled)

        # Remove locale from the session when set to "Browser Locale" and editing self
        session.delete(:locale) if params[:user][:locale].try(:empty?)
      end
    end
  end

  def update_admin_flag
    # Only an admin can update admin attribute of another user
    # this is required, as the admin field is blacklisted above
    @user.admin = @admin if User.current.admin && !@admin.nil?
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

  def set_current_taxonomies(user, options = {})
    session ||= options.fetch(:session, {})
    ['location', 'organization'].each do |taxonomy|
      default_taxonomy = user.send "default_#{taxonomy}"
      if default_taxonomy.present?
        taxonomy.classify.constantize.send 'current=', default_taxonomy
        session["#{taxonomy}_id"] = default_taxonomy.id
      end
    end
  end

  module_function :set_current_taxonomies
end
