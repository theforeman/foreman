class LookupKeysController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :setup_search_options, :only => :index

  def index
    base = LookupKey.authorized(:view_external_variables)
    begin
      values = base.search_for(params[:search], :order => params[:order]).includes(:param_classes)
    rescue => e
      error e.to_s
      values = base.search_for ""
    end
    @lookup_keys = values.includes(:puppetclass).paginate(:page => params[:page])
    @authorizer  = Authorizer.new(User.current, @lookup_keys)
    @puppetclass_authorizer = Authorizer.new(User.current, @lookup_keys.map(&:param_class).compact.uniq)
  end

  def edit
    @lookup_key = find_by_key(:edit_external_variables)
  end

  def update
    @lookup_key = find_by_key(:edit_external_variables)
    if @lookup_key.update_attributes(params[:lookup_key])
      process_success
    else
      process_error
    end
  end

  def destroy
    @lookup_key = find_by_key(:destroy_external_variables)
    if @lookup_key.destroy
      process_success
    else
      process_error
    end
  end

  private
  def find_by_key(permission = :view_external_variables)
    if params[:id]
      lookup_key = LookupKey.authorized(permission).find(params[:id])
      not_found and return if lookup_key.blank?
      lookup_key
    end
  end
end
