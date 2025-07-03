class OperatingsystemsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Operatingsystem

  before_action :find_resource, :only => [:edit, :update, :destroy, :clone]

  def index
    @operatingsystems = resource_base_search_and_page
  end

  def new
    @operatingsystem = Operatingsystem.new
  end

  # TODO: Update API controller as well
  def create
    if params[:cloned_os_id]
      @operatingsystem = CloneOperatingSystem.clone_obj(Operatingsystem.find(params[:cloned_os_id]), operatingsystem_params)
    else
      @operatingsystem = Operatingsystem.new(operatingsystem_params)
    end

    if @operatingsystem.save
      process_success
    else
      process_error
    end
  end

  def edit
    # Generates default OS template entries
    @operatingsystem.provisioning_templates.map(&:template_kind_id).uniq.each do |kind|
      if @operatingsystem.os_default_templates.where(:template_kind_id => kind).blank?
        @operatingsystem.os_default_templates.build(:template_kind_id => kind)
      end
    end
  end

  def update
    if @operatingsystem.update(operatingsystem_params)
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

  def clone
    @cloned_os = @operatingsystem
    @operatingsystem = CloneOperatingSystem.clone_obj(@cloned_os)
  end

  private

  def action_permission
    case params[:action]
      when 'clone'
        :create
      else
        super
    end
  end
end
