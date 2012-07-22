module PuppetclassesAndEnvironmentsHelper
  def class_update_text pcs, env
    if pcs.empty?
      "Empty environment"
    elsif pcs == ["_destroy_"]
      "Deleted environment"
    elsif pcs.delete "_destroy_"
      "Deleted environment #{env} and " + pcs.to_sentence
    else
      pcs.to_sentence
    end
  end

  def import_proxy_select hash
    proxies = Environment.find_import_proxies
    toolbar_action_buttons(
      proxies.map do |proxy|
        display_link_if_authorized("Import from #{proxy.name}", hash.merge(:proxy => proxy))
      end.flatten
    )
  end
end
