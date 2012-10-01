module PuppetclassesAndEnvironmentsHelper
  def class_update_text pcs, env
    if pcs.empty?
      "Empty environment"
    elsif pcs == ["_destroy_"]
      "Deleted environment"
    elsif pcs.delete "_destroy_"
      "Deleted environment #{env} and " + pcs.to_sentence
    else
      pretty_print(pcs.is_a?(Hash) ? pcs.keys : pcs)
    end
  end

  def import_proxy_select hash
    toolbar_action_buttons(
      SmartProxy.puppet_proxies.map do |proxy|
        display_link_if_authorized("Import from #{proxy.name}", hash.merge(:proxy => proxy))
      end.flatten
    )
  end

  private
  def pretty_print classes
    hash = { }
    classes.each do |klass|
      if (mod = klass.gsub(/::.*/, ""))
        hash[mod] ||= []
        hash[mod] << klass
      else
        next
      end
    end
    hash.keys.sort.map do |key|
      link_to_function key, { :rel => "popover", "data-content" => hash[key].sort.join('<br>').html_safe, "data-original-title" => key }
    end.to_sentence.html_safe

  end

end
