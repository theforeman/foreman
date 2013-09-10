class OperatingsystemsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_os, :only => %w{show edit update destroy bootfiles}

  def index
    @operatingsystems = Operatingsystem.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    @counter = Host.count(:group => :operatingsystem_id, :conditions => {:operatingsystem_id => @operatingsystems.all})
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
    # Generates default OS template entries
    @operatingsystem.config_templates.map(&:template_kind_id).uniq.each do |kind|
      if @operatingsystem.os_default_templates.where(:template_kind_id => kind).blank?
        @operatingsystem.os_default_templates.build(:template_kind_id => kind)
      end
    end if SETTINGS[:unattended]
  end

  def update
    if @operatingsystem.update_attributes(params[:operatingsystem])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @operatingsystem.destroy
      process_success
    else
      process_error
    end
  end

  private
  def find_os
    @operatingsystem = Operatingsystem.find(params[:id])
  end

end
