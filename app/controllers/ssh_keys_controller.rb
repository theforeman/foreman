class SshKeysController < ApplicationController
  include Foreman::Controller::Parameters::SshKey
  include Foreman::Controller::UserAware

  before_action :find_resource, :only => [:destroy]

  def new
    @ssh_key = SshKey.new
  end

  def create
    @ssh_key = SshKey.new(ssh_key_params.merge(:user => @user))
    if @ssh_key.save
      process_success :success_redirect => edit_user_path(@user)
    else
      process_error
    end
  end

  def destroy
    if @ssh_key.destroy
      process_success :success_redirect => edit_user_path(@user)
    else
      process_error
    end
  end
end
