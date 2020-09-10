module EnvironmentsHelper
  include PuppetclassesAndEnvironmentsHelper

  def environments_title_actions
    title_actions import_proxy_select(hash_for_import_environments_environments_path),
      button_group(new_link(_('Create Puppet Environment'))),
      button_group(help_button)
  end
end
