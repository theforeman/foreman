class ConfigTemplatesController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        @search = ConfigTemplate.search params[:search]
        @config_templates = @search.paginate(:page => params[:page], :include => [:template_kind, :environments,:hostgroups])
      end
      format.json { render :json => ConfigTemplate }
    end

  end

  def new
    @config_template = ConfigTemplate.new
    @config_template.template_combinations.build
  end

  def create
    @config_template = ConfigTemplate.new(params[:config_template])
    if @config_template.save
      notice "Successfully created config template."
      redirect_to config_templates_url
    else
      render :action => 'new'
    end
  end

  def edit
    @config_template = ConfigTemplate.find(params[:id])
    @config_template.template_combinations.build if @config_template.template_combinations.empty?
  end

  def update
    @config_template = ConfigTemplate.find(params[:id])
    if @config_template.update_attributes(params[:config_template])
      notice "Successfully updated config template."
      redirect_to config_templates_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @config_template = ConfigTemplate.find(params[:id])
    @config_template.destroy
    notice "Successfully destroyed config template."
    redirect_to config_templates_url
  end
end
