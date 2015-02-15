module EnvironmentsHelper
  include PuppetclassesAndEnvironmentsHelper

  def environments_title_actions
    title_actions import_proxy_select(hash_for_import_environments_environments_path),
                  button_group(display_link_if_authorized(_('New Puppet Environment'), hash_for_new_environment_path))
  end
end
