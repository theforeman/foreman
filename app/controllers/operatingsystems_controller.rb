class OperatingsystemsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_os, :only => %w{show edit update destroy bootfiles templates_for_type}

  def index
    values = Operatingsystem.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html do
        @operatingsystems = values.paginate(:page => params[:page])
        @counter = Host.count(:group => :operatingsystem_id, :conditions => {:operatingsystem_id => @operatingsystems})
      end
      format.json { render :json => values.all(:include => [:media, :architectures, :ptables]) }
    end
  end

  def new
    @operatingsystem = Operatingsystem.new
    @operatingsystem.os_parameters.build
    @operatingsystem.os_default_templates.build
  end

  def show
    respond_to do |format|
      format.json { render :json => @operatingsystem }
    end
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
    @operatingsystem.os_parameters.build if @operatingsystem.os_parameters.empty?
    @operatingsystem.os_default_templates.build if @operatingsystem.os_default_templates.empty?
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

  def bootfiles
    medium = Medium.find_by_name(params[:medium])
    arch =  Architecture.find_by_name(params[:architecture])
    respond_to do |format|
      format.json { render :json => @operatingsystem.pxe_files(medium, arch)}
    end
  rescue => e
    respond_to do |format|
      format.json { render :json => e.to_s, :status => :unprocessable_entity }
    end
  end

  def templates_for_type
    return head(:method_not_allowed) unless request.xhr?
    if @operatingsystem and params[:template_kind_id].to_i > 0 and kind = TemplateKind.find(params[:template_kind_id])
      render :partial => 'template', :locals => {:templates => ConfigTemplate.template_kind_id_eq(kind.id).operatingsystems_id_eq(@operatingsystem.id), :fid => params[:fid]}
    else
      return head(:not_found)
    end
  end

  private
  def find_os
    @operatingsystem = Operatingsystem.find(params[:id])
  end

end
