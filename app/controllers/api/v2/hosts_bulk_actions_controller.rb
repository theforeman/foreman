module Api
  module V2
    class HostsBulkActionsController < V2::BaseController
      include Api::Version2
      include Api::V2::BulkHostsExtension

      before_action :find_deletable_hosts, :only => [:bulk_destroy]
      before_action :find_editable_hosts, :only => [:build, :reassign_hostgroup, :change_owner, :disassociate, :change_power_state]
      before_action :validate_power_action, :only => [:change_power_state]

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

      api :PUT, "/hosts/bulk/change_power_state", N_("Change power state")
      param_group :bulk_host_ids
      param :power, String, :required => true, :desc => N_("Power action to perform (start, stop, poweroff, reboot, reset, soft, cycle)")
      def change_power_state
        action = params[:power]

        manager = BulkHostsManager.new(hosts: @hosts)
        result = manager.change_power_state(action)

        failed_hosts         = result[:failed_hosts] || []
        failed_host_ids      = result[:failed_host_ids] || []
        unsupported_hosts    = result[:unsupported_hosts] || []
        unsupported_host_ids = result[:unsupported_host_ids] || []

        if failed_hosts.empty? && unsupported_hosts.empty?
          render json: {
            message: _('The power state of the selected hosts will be set to %s') % _(action),
          }, status: :ok
        else
          total_failed      = failed_hosts.size
          total_unsupported = unsupported_hosts.size

          parts = []
          if total_failed > 0
            parts << n_(
              "Failed to set power state for %s host.",
              "Failed to set power state for %s hosts.",
              total_failed
            ) % total_failed
          end

          if total_unsupported > 0
            parts << n_(
              "%s host does not support power management.",
              "%s hosts do not support power management.",
              total_unsupported
            ) % total_unsupported
          end

          render json: {
            error: {
              message: parts.join(' '),
              failed_host_ids: (failed_host_ids + unsupported_host_ids).uniq,
              failed_hosts: failed_hosts,
              unsupported_hosts: unsupported_hosts,
            },
          }, status: :unprocessable_entity
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

      api :PUT, "/hosts/bulk/change_owner", N_("Change owner")
      param_group :bulk_host_ids
      param :owner_id, :number, :required => true, :desc => N_("ID of the owner to reassign the hosts to")
      def change_owner
        BulkHostsManager.new(hosts: @hosts).change_owner(params[:owner_id])
        process_response(true, { :message => n_("Updated host: changed owner", "Updated hosts: changed owner", @hosts.count)})
      end

      api :PUT, "/hosts/bulk/disassociate", N_("Disassociate compute resources")
      param_group :bulk_host_ids
      def disassociate
        BulkHostsManager.new(hosts: @hosts).disassociate
        process_response(true, { :message => n_("Updated host: Disassociated from compute resource",
          "Updated hosts: Disassociated from compute resource", @hosts.count)})
      end

      api :PUT, "/hosts/bulk/assign_organization", N_("Assign organization")
      param_group :bulk_host_ids
      param :id, :number, :required => true, :desc => N_("The organization ID to assign the hosts to")
      param :mismatch_setting, :bool, :required => true, :desc => N_("Fix organization on mismatch")
      def assign_organization
        without_taxonomy do
          find_editable_hosts
          taxonomy = Organization.find(params[:id])
          BulkHostsManager.new(hosts: @hosts).assign_taxonomy(taxonomy, params[:mismatch_setting])
          message = _("Organization is set to %s") % taxonomy.name
          process_response(true, { :message => n_("Updated host: #{message}", "Updated hosts: #{message}", @hosts.count)})
        end
      end

      api :PUT, "/hosts/bulk/assign_location", N_("Assign location")
      param_group :bulk_host_ids
      param :id, :number, :required => true, :desc => N_("The location ID to assign the hosts to")
      param :mismatch_setting, :bool, :required => true, :desc => N_("Fix location on mismatch")
      def assign_location
        without_taxonomy do
          find_editable_hosts
          taxonomy = Location.find(params[:id])
          BulkHostsManager.new(hosts: @hosts).assign_taxonomy(taxonomy, params[:mismatch_setting])
          message = _("Location is set to %s") % taxonomy.name
          process_response(true, { :message => n_("Updated host: #{message}", "Updated hosts: #{message}", @hosts.count)})
        end
      end

      protected

      def action_permission
        case params[:action]
        when 'build', 'change_power_state'
          'edit'
        else
          super
        end
      end

      private

      def find_deletable_hosts
        find_bulk_hosts(:destroy_hosts, included: params)
      end

      def find_editable_hosts
        find_bulk_hosts(:edit_hosts, params)
      end

      def without_taxonomy
        context = Foreman::ThreadSession::Context.get
        Foreman::ThreadSession::Context.set(user: context[:user])
        yield
      rescue => e
        render_error(:custom_error, :status => :unprocessable_entity, :locals => { :message => e.message})
      ensure
        Foreman::ThreadSession::Context.set(**context) if context
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

      def validate_power_action
        action   = params[:power]
        host_ids = @hosts&.map(&:id) || []

        return true if action.present? && PowerManager::REAL_ACTIONS.include?(action)

        if action.blank?
          render json: {
            error: {
              message: _("Power action is required"),
              failed_host_ids: host_ids,
            },
          }, status: :unprocessable_entity
        else
          render json: {
            error: {
              message: _("Invalid power action"),
              valid_power_actions: PowerManager::REAL_ACTIONS,
              failed_host_ids: host_ids,
            },
          }, status: :unprocessable_entity
        end
        false
      end
    end
  end
end
