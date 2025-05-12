module Foreman::Controller::TaxonomyMultiple
  extend ActiveSupport::Concern

  included do
    # TODO: make this before filter work, its not working as the same filter is defined in the hosts controller
    # before_action :find_multiple, :only => [:select_multiple_organization, :update_multiple_organization,
    #                                        :select_multiple_location,     :update_multiple_location]
  end

  def select_multiple_organization
    @hosts = find_multiple
  end

  def select_multiple_location
    @hosts = find_multiple
  end

  def update_multiple_organization
    @hosts = find_multiple
    update_multiple_taxonomies(:organization)
  end

  def update_multiple_location
    @hosts = find_multiple
    update_multiple_taxonomies(:location)
  end

  private

  def update_multiple_taxonomies(type)
    # simple validations
    if params[type].nil? || (id = params[type][:id]).blank?
      error "No #{type.to_s.classify} selected!"
      redirect_to(helpers.current_hosts_path)
      return
    end

    taxonomy = Taxonomy.find_by_id(id)
    begin
      BulkHostsManager.new(hosts: @hosts).assign_taxonomy(taxonomy, params[type][:optimistic_import] == 'yes')
      success "Updated hosts: Changed #{type.to_s.classify}"
    rescue => e
      error e.message
    end
    redirect_back_or_to helpers.current_hosts_path
  end
end
