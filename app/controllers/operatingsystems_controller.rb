class OperatingsystemsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_os, :only => %w{edit update destroy bootfiles}

  def index
    @operatingsystems = Operatingsystem.authorized(:view_operatingsystems).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    @host_counter     = Host.group(:operatingsystem_id).where(:operatingsystem_id => @operatingsystems.collect(&:id)).count
  end

  def new
    @operatingsystem = Operatingsystem.new
  end

  def create
    @operatingsystem = Operatingsystem.new(params[:operatingsystem])
    if @operatingsystem.save
      process_success
    else
      process_error
    end
  end

  def edit
    @operatingsystem = find_os(:edit_operatingsystems)
    # Generates default OS template entries
    @operatingsystem.config_templates.map(&:template_kind_id).uniq.each do |kind|
      if @operatingsystem.os_default_templates.where(:template_kind_id => kind).blank?
        @operatingsystem.os_default_templates.build(:template_kind_id => kind)
      end
    end if SETTINGS[:unattended]
  end

  def update
    @operatingsystem = find_os(:edit_operatingsystems)
    if @operatingsystem.update_attributes(params[:operatingsystem])
      process_success
    else
      process_error
    end
  end

  def destroy
    @operatingsystem = find_os(:destroy_operatingsystems)
    if @operatingsystem.destroy
      process_success
    else
      process_error
    end
    @operatingsystem = generalize(@operatingsystem)
  end

  private

  def find_os(permission = :view_operatingsystems)
    Operatingsystem.authorized(permission).find(params[:id])
  end

end
