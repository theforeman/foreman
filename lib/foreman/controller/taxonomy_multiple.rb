module Foreman::Controller::TaxonomyMultiple
  extend ActiveSupport::Concern

  included do
    #TODO: make this before filter work, its not working as the same filter is defined in the hosts controller
    #before_filter :find_multiple, :only => [:select_multiple_organization, :update_multiple_organization,
    #                                        :select_multiple_location,     :update_multiple_location]
  end

  module InstanceMethods
    def select_multiple_organization
      find_multiple
    end

    def select_multiple_location
      find_multiple
    end

    def update_multiple_organization
      find_multiple
      update_multiple_taxonomies(:organization)
    end

    def update_multiple_location
      find_multiple
      update_multiple_taxonomies(:location)
    end

    private

    def update_multiple_taxonomies type
      # simple validations
      if (params[type].nil?) or (id=params[type][:id]).nil?
        error "No #{type.to_s.classify} selected!"
        redirect_to(hosts_path) and return
      end

      taxonomy = Taxonomy.find_by_id(id)

      mismatched_hosts = []
      #update the hosts
      @hosts.update_all("#{type}_id=".to_sym => taxonomy.id)
      @hosts.each do |host|
        host.import_missing_ids if params[type][:optimistic_import] == 'yes'
        if host.matching?
          host.save(:validate => false)
        else
          mismatched_hosts << host
        end
      end

      if mismatched_hosts.any?
        error render_to_string(:partial => 'hosts/taxonomy_mismatch', :locals => { :hosts => mismatched_hosts, :taxonomy => taxonomy })
        redirect_to(hosts_path) and return
      else
        notice "Updated hosts: Changed #{type.to_s.classify}"
        redirect_back_or_to hosts_path
      end
    end
  end

end