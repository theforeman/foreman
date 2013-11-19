class PuppetclassesController < ApplicationController
  include Foreman::Controller::Environments
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => [:edit, :update, :destroy, :assign]
  before_filter :setup_search_options, :only => :index
  before_filter :reset_redirect_to_url, :only => :index
  before_filter :store_redirect_to_url, :only => :edit

  def index
    begin
      values = Puppetclass.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = Puppetclass.search_for ""
    end
    @puppetclasses = values.paginate(:page => params[:page])
    @system_counter = System.group(:puppetclass_id).joins(:puppetclasses).where(:puppetclasses => {:id => @puppetclasses.collect(&:id)}).count
    @keys_counter = Puppetclass.joins(:class_params).select('distinct environment_classes.lookup_key_id').group(:name).count
  end

  def new
    @puppetclass = Puppetclass.new
  end

  def create
    @puppetclass = Puppetclass.new(params[:puppetclass])
    if @puppetclass.save
      notice _("Successfully created puppetclass.")
      redirect_to puppetclasses_url
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @puppetclass.update_attributes(params[:puppetclass])
      notice _("Successfully updated puppetclass.")
      redirect_back_or_default(puppetclasses_url)
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @puppetclass.destroy
      notice _("Successfully destroyed puppetclass.")
    else
      error @puppetclass.errors.full_messages.join("<br/>")
    end
    redirect_to puppetclasses_url
  end

  # form AJAX methods
  def parameters
    puppetclass = Puppetclass.find(params[:id])
    render :partial => "puppetclasses/class_parameters", :locals => {
        :puppetclass => puppetclass,
        :obj => get_system_or_system_group}
  end

  private

  def get_system_or_system_group
    # params['system_id'] = 'null' if NEW since systems/form and system_groups/form has data-id="null"
    if params['system_id'] == 'null'
      @obj = System::Managed.new(params['system']) if params['system']
      @obj ||= SystemGroup.new(params['system_group']) if params['system_group']
    else
      if params['system']
        @obj = System::Base.find(params['system_id'])
        unless @obj.kind_of?(System::Managed)
          @obj      = @obj.becomes(System::Managed)
          @obj.type = "System::Managed"
        end
        # puppetclass_ids is removed since it causes an insert on system_classes before form is submitted
        @obj.attributes = params['system'].except!(:puppetclass_ids)
      elsif params['system_group']
        # system_group.id is assigned to params['system_id'] by system_edit.js#load_puppet_class_parameters
        @obj = SystemGroup.find(params['system_id'])
        # puppetclass_ids is removed since it causes an insert on system_group_classes before form is submitted
        @obj.attributes = params['system_group'].except!(:puppetclass_ids)
      end
    end
    @obj
  end

  def reset_redirect_to_url
    session[:redirect_to_url] = nil
  end

  def store_redirect_to_url
    session[:redirect_to_url] ||= request.referer
  end

  def redirect_back_or_default(default)
    redirect_to(session[:redirect_to_url] || default)
    session[:redirect_to_url] = nil
  end

  def find_by_name
    not_found and return if params[:id].blank?
    @puppetclass = (params[:id] =~ /\A\d+\Z/) ? Puppetclass.find(params[:id]) : Puppetclass.find_by_name(params[:id])
    not_found and return unless @puppetclass
  end
end
