class OperatingsystemsController < ApplicationController
  before_filter :find_os, :only => %w{show edit update destroy bootfiles templates_for_type}

  def index
    respond_to do |format|
      format.html do
        @search           = Operatingsystem.search(params[:search])
        @operatingsystems = @search.all.paginate(:page => params[:page], :include => [:architectures], :order => :name)
      end
      format.json { render :json => Operatingsystem.all(:include => [:medias, :architectures, :ptables]) }
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
      notice "Successfully created operatingsystem."
      redirect_to operatingsystems_url
    else
      render :action => 'new'
    end
  end

  def edit
    @operatingsystem.os_parameters.build if @operatingsystem.os_parameters.empty?
    @operatingsystem.os_default_templates.build if @operatingsystem.os_default_templates.empty?
  end

  def update
    if @operatingsystem.update_attributes(params[:operatingsystem])
      notice "Successfully updated operatingsystem."
      redirect_to operatingsystems_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @operatingsystem.destroy
      notice "Successfully destroyed operatingsystem."
    else
      error @operatingsystem.errors.full_messages.join("<br/>")
    end
    redirect_to operatingsystems_url
  end

  def bootfiles
    media = Media.find_by_name(params[:media])
    arch =  Architecture.find_by_name(params[:architecture])
    respond_to do |format|
      format.json { render :json => @operatingsystem.pxe_files(media, arch)}
    end
  rescue => e
    respond_to do |format|
      format.json { render :json => e.to_s, :status => :unprocessable_entity }
    end
  end

  def templates_for_type
    return head(:method_not_allowed) unless request.xhr?
    if params[:template_kind_id].to_i > 0 and kind = TemplateKind.find(params[:template_kind_id]) and @operatingsystem
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
