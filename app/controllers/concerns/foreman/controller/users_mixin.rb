module Foreman::Controller::UsersMixin
  extend ActiveSupport::Concern
  include Foreman::Controller::UserSelfEditing

  included do
    before_action :clear_session_locale_on_update, :only => :update
  end

  def resource_scope(options = {})
    super(options).except_hidden
  end

  protected

  def clear_session_locale_on_update
    if params[:user] && editing_self?
      # Remove locale from the session when set to "Browser Locale" and editing self
      session.delete(:locale) if params[:user][:locale].try(:empty?)
    end
  end

  def update_sub_hostgroups_owners
    return if params[:user]['hostgroup_ids'].empty?
    hostgroup_ids = params[:user]['hostgroup_ids'].reject(&:empty?).map(&:to_i)
    return if hostgroup_ids.empty?

    sub_hg = Hostgroup.where(:id => hostgroup_ids).map(&:subtree).flatten.reject { |hg| hg.user_ids.include?(@user.id) }
    sub_hg.each { |hg| hg.users << @user }
  end
end
