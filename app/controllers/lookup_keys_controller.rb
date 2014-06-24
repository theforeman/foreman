class LookupKeysController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :setup_search_options, :only => :index
  before_filter :find_by_key, :only => [:edit, :update, :destroy], :if => Proc.new { params[:id] }

  def index
    @lookup_keys = resource_base.search_for(params[:search], :order => params[:order]).includes(:param_classes, :puppetclass).paginate(:page => params[:page])
    @puppetclass_authorizer = Authorizer.new(User.current, :collection => @lookup_keys.map(&:puppetclass_id).compact.uniq)
  end

  def edit
  end

  def update
    if @lookup_key.update_attributes(params[:lookup_key])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @lookup_key.destroy
      process_success
    else
      process_error
    end
  end

  private

  def find_by_key
    @lookup_key = resource_base.find(params[:id])
    not_found and return if @lookup_key.blank?
    @lookup_key
  end

  def controller_permission
    'external_variables'
  end
end
