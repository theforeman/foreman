class RealmsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::Realm

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @realms = resource_base_search_and_page
  end

  def new
    @realm = Realm.new
  end

  def create
    @realm = Realm.new(realm_params)
    if @realm.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @realm.update(realm_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @realm.destroy
      process_success
    else
      process_error
    end
  end
end
