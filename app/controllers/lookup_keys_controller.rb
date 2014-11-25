class LookupKeysController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :setup_search_options, :only => :index
  before_filter :find_resource, :only => [:edit, :update, :destroy], :if => Proc.new { params[:id] }

  def index
    @lookup_keys = resource_base.search_for(params[:search], :order => params[:order])
                                .includes(:param_classes)
                                .paginate(:page => params[:page])
    @puppetclass_authorizer = Authorizer.new(User.current, :collection => @lookup_keys.map(&:puppetclass_id).compact.uniq)
  end

  def edit
  end

  def update
    if @lookup_key.update_attributes(foreman_params)
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

  def controller_permission
    'external_variables'
  end
end
