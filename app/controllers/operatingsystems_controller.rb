class OperatingsystemsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Operatingsystem

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @operatingsystems = resource_base_search_and_page
  end

  def new
    @operatingsystem = Operatingsystem.new
  end

  def create
    @operatingsystem = Operatingsystem.new(operatingsystem_params)
    if @operatingsystem.save
      process_success
    else
      process_error
    end
  end

  def edit
    # Generates default OS template entries
    if SETTINGS[:unattended]
      @operatingsystem.provisioning_templates.map(&:template_kind_id).uniq.each do |kind|
        if @operatingsystem.os_default_templates.where(:template_kind_id => kind).blank?
          @operatingsystem.os_default_templates.build(:template_kind_id => kind)
        end
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
end
