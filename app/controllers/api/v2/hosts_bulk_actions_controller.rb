module Api
  module V2
    class HostsBulkActionsController < V2::BaseController
      include Api::Version2
      include Api::V2::BulkHostsExtension

      before_action :find_deletable_hosts, :only => [:bulk_destroy]
      before_action :find_editable_hosts, :only => [:build, :reassign_hostgroup]

      def_param_group :bulk_host_ids do
        param :organization_id, :number, :required => true, :desc => N_("ID of the organization")
        param :included, Hash, :desc => N_("Hosts to include in the action"), :required => true, :action_aware => true do
          param :search, String, :required => false, :desc => N_("Search string describing which hosts to perform the action on")
          param :ids, Array, :required => false, :desc => N_("List of host ids to perform the action on")
        end
        param :excluded, Hash, :desc => N_("Hosts to explicitly exclude in the action."\
                                           " All other hosts will be included in the action,"\
                                           " unless an included parameter is passed as well."), :required => true, :action_aware => true do
          param :ids, Array, :required => false, :desc => N_("List of host ids to exclude and not perform the action on")
        end
      end

      api :DELETE, "/hosts/bulk/", N_("Delete multiple hosts")
      param_group :bulk_host_ids
      def bulk_destroy
        process_response @hosts.destroy_all
      end

      api :PUT, "/hosts/bulk/build", N_("Build")
      param_group :bulk_host_ids
      param :reboot, :bool, N_("Reboot after build. Ignored if rebuild_configuration is passed.")
      param :rebuild_configuration, :bool, N_("Rebuild configuration only")
      def build
        if Foreman::Cast.to_bool(params[:rebuild_configuration])
          rebuild_config
        else
          reboot = Foreman::Cast.to_bool(params[:reboot])
          manager = BulkHostsManager.new(hosts: @hosts)
          missed_hosts = manager.build(reboot: reboot)
          if missed_hosts.empty?
            if reboot
              process_response(true, { :message => n_("%s host set to build and rebooting.",
                "%s hosts set to build and rebooting.",
                @hosts.count) % @hosts.count,
                                      })
            else
              process_response(true, { :message => n_("Built %s host",
                "Built %s hosts", @hosts.count) % @hosts.count })
            end
          elsif reboot
            render_error(:bulk_hosts_error, :status => :unprocessable_entity,
                        :locals => { :message => n_("Failed to build and reboot %s host",
                          "Failed to build and reboot %s hosts", missed_hosts.count) % missed_hosts.count,
                                     :failed_host_ids => missed_hosts.map(&:id),
                                   })
          else
            render_error(:bulk_hosts_error, :status => :unprocessable_entity,
                         :locals => { :message => n_("Failed to build %s host",
                           "Failed to build %s hosts", missed_hosts.count) % missed_hosts.count,
                                      :failed_host_ids => missed_hosts.map(&:id),
                                    })
          end
        end
      end

      api :PUT, "/hosts/bulk/reassign_hostgroups", N_("Reassign hostgroups")
      param_group :bulk_host_ids
      param :hostgroup_id, :number, :desc => N_("ID of the hostgroup to reassign the hosts to")
      def reassign_hostgroup
        hostgroup = params[:hostgroup_id].present? ? Hostgroup.find(params[:hostgroup_id]) : nil
        BulkHostsManager.new(hosts: @hosts).reassign_hostgroups(hostgroup)
        if hostgroup
          process_response(true, { :message => n_("Reassigned %{count} host to hostgroup %{hostgroup}",
            "Reassigned %{count} hosts to hostgroup %{hostgroup}", @hosts.count) % {count: @hosts.count, hostgroup: hostgroup.name} })
        else
          process_response(true, { :message => n_("Removed assignment of host group from %s host",
            "Removed assignment of host group from %s hosts", @hosts.count) % @hosts.count })
        end
      end

      protected

      def action_permission
        case params[:action]
        when 'build'
          'edit'
        else
          super
        end
      end

      private

      def find_deletable_hosts
        find_bulk_hosts(:destroy_hosts, params)
      end

      def find_editable_hosts
        find_bulk_hosts(:edit_hosts, params)
      end

      def rebuild_config
        all_fails = BulkHostsManager.new(hosts: @hosts).rebuild_configuration
        failed_host_ids = all_fails.flat_map { |_key, values| values&.map(&:id) }
        failed_host_ids.compact!
        failed_host_ids.uniq!

        if failed_host_ids.empty?
          process_response(true, { :message => n_("Rebuilt configuration for %s host",
            "Rebuilt configuration for %s hosts",
            @hosts.count) % @hosts.count })
        else
          render_error(:bulk_hosts_error, :status => :unprocessable_entity,
                      :locals => { :message => n_("Failed to rebuild configuration for %s host",
                        "Failed to rebuild configuration for %s hosts",
                        failed_host_ids.count) % failed_host_ids.count,
                                   :failed_host_ids => failed_host_ids,
                                 }
          )
        end
      end
    end
  end
end
