# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE  See the
# GNU General Public License for more details
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

module Foreman
  module DefaultData
    class DataAlreadyLoaded < Exception; end

    module Loader
      class << self
        # Returns true if no data is already loaded in the database
        # otherwise false
        def no_data?
          !Role.first(:conditions => {:builtin => 0})
        end

        # Loads the default data
        # Raises a RecordNotSaved exception if something goes wrong
        def load(reset=false)

          # We may be executing something like rake db:migrate:reset, which destroys this table; only continue if the table exists
          Role.count rescue return
          Role.transaction do
            # Roles
            manager = Role.where(:name => "Manager").empty? ? Role.create(:name => "Manager") : Role.where(:name => "Manager")[0]
            if reset or manager.permissions.empty?
              manager.update_attribute :permissions, manager.setable_permissions.collect {|p| p.name}
            end

            ptable_editor =  Role.where(:name => "Edit partition tables").empty? ? Role.create(:name => "Edit partition tables") : Role.where(:name => "Edit partition tables")[0]
            if reset or ptable_editor.permissions.empty?
              ptable_editor.update_attribute :permissions, [:view_ptables, :create_ptables, :edit_ptables, :destroy_ptables]
            end

            hosts_reader =  Role.where(:name => "View hosts").empty? ? Role.create(:name => "View hosts") : Role.where(:name => "View hosts")[0]
            if reset or hosts_reader.permissions.empty?
              hosts_reader.update_attribute :permissions, [:view_hosts]
            end

            hosts_editor =  Role.where(:name => "Edit hosts").empty? ? Role.create(:name => "Edit hosts") : Role.where(:name => "Edit hosts")[0]
            if reset or hosts_editor.permissions.empty?
              hosts_editor.update_attribute :permissions, [:view_hosts,    :edit_hosts,    :create_hosts,    :destroy_hosts, :build_hosts]
            end

            viewer =  Role.where(:name => "Viewer").empty? ? Role.create(:name => "Viewer") : Role.where(:name => "Viewer")[0]
            if reset or viewer.permissions.empty?
              viewer.update_attribute :permissions, [:view_hosts,
                :view_puppetclasses,
                :view_hostgroups,
                :view_domains,
                :view_operatingsystems,
                :view_locations,
                :view_media,
                :view_models,
                :view_environments,
                :view_architectures,
                :view_ptables,
                :view_globals,
                :view_external_variables,
                :view_authenticators,
                :access_settings,
                :access_dashboard,
                :view_reports,
                :view_facts,
                :view_smart_proxies,
                :view_subnets,
                :view_statistics,
                :view_organizations,
                :view_usergroups,
                :view_users,
                :view_audit_logs]
            end

            siteman = Role.where(:name => "Site manager").empty? ? Role.create(:name => "Site manager") : Role.where(:name => "Site manager")[0]
            if reset or siteman.permissions.empty?
              siteman.update_attribute :permissions, [ :view_architectures,
                :view_audit_logs,
                :view_authenticators,
                :access_dashboard,
                :view_domains,
                :view_environments,
                :import_environments,
                :view_external_variables,
                :create_external_variables,
                :edit_external_variables,
                :destroy_external_variables,
                :view_facts,
                :view_globals,
                :view_hostgroups,
                :view_hosts,
                :view_smart_proxies_puppetca,
                :view_smart_proxies_autosign,
                :create_hosts,
                :edit_hosts,
                :destroy_hosts,
                :build_hosts,
                :view_media,
                :create_media,
                :edit_media,
                :destroy_media,
                :view_models,
                :view_operatingsystems,
                :view_ptables,
                :view_puppetclasses,
                :import_puppetclasses,
                :view_reports,
                :destroy_reports,
                :access_settings,
                :view_smart_proxies,
                :edit_smart_proxies,
                :view_subnets,
                :edit_subnets,
                :view_statistics,
                :view_usergroups,
                :create_usergroups,
                :edit_usergroups,
                :destroy_usergroups,
                :view_users,
                :edit_users]
            end
            if reset or Role.default_user.permissions.empty?
              Role.default_user.update_attribute :permissions, [:view_hosts,
                :view_puppetclasses,
                :view_hostgroups,
                :view_domains,
                :view_operatingsystems,
                :view_media,
                :view_models,
                :view_environments,
                :view_architectures,
                :view_ptables,
                :view_globals,
                :view_external_variables,
                :view_authenticators,
                :access_settings,
                :access_dashboard,
                :view_reports,
                :view_subnets,
                :view_facts,
                :view_locations,
                :view_organizations,
                :view_statistics]
            end
            if reset or Role.anonymous.permissions.empty?
              Role.anonymous.update_attribute :permissions, [:view_hosts, :view_bookmarks, :view_tasks]
            end
          end
          true
        end
      end
    end
  end
end
