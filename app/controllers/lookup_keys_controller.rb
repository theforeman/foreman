class LookupKeysController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :setup_search_options, :only => :index

  def index
    @lookup_keys = LookupKey.authorized(:view_external_variables).search_for(params[:search], :order => params[:order]).includes(:puppetclass).paginate(:page => params[:page])
    @puppetclass_authorizer = Authorizer.new(User.current, @lookup_keys.map(&:puppetclass_id).compact.uniq)
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
