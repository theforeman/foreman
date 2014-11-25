class FiltersController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_role
  before_filter :setup_search_options, :only => :index

  def index
    @filters = resource_base.includes(:role, :permissions).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    @roles_authorizer = Authorizer.new(User.current, :collection => @filters.map(&:role_id))
  end

  def new
    @filter = resource_base.build
  end

  def create
    @filter = Filter.new(foreman_params)
    if @filter.save
      process_success :success_redirect => saved_redirect_url_or(filters_path(:role_id => @role))
    else
      process_error
    end
  end

  def edit
    @filter = resource_base.includes(:permissions).find(params[:id])
  end

  def update
    @filter = resource_base.find(params[:id])
    if @filter.update_attributes(foreman_params)
      process_success :success_redirect => saved_redirect_url_or(filters_path(:role_id => @role))
    else
      process_error
    end
  end

  def destroy
    @filter = resource_base.find(params[:id])
    if @filter.destroy
      process_success :success_redirect => saved_redirect_url_or(filters_path(:role_id => @role))
    else
      process_error
    end
  end

  protected

  def find_role
    @role = Role.find_by_id(role_id)
  end

  def resource_base
    @resource_base ||= @role.present? ?
        @role.filters.authorized(current_permission) :
        Filter.scoped.authorized(current_permission)
  end

  def role_id
    params[:role_id]
  end

  def setup_search_options
    @original_search_parameter = params[:search]
    params[:search] ||= ""
    params.keys.each do |param|
      if param =~ /role_id$/
        unless (role = Role.find_by_id(params[param])).blank?
          query = "role_id = #{role.id}"
          params[:search] += query unless params[:search].include? query
        end
      elsif param =~ /(\w+)_id$/
        unless params[param].blank?
          query = "#{$1} = #{params[param]}"
          params[:search] += query unless params[:search].include? query
        end
      end
    end
  end
end
