module PuppetclassesAndEnvironmentsHelper
  def class_update_text pcs, env
    if pcs.empty?
      _("Empty environment")
    elsif pcs == ["_destroy_"]
      _("Deleted environment")
    elsif pcs.delete "_destroy_"
      _("Deleted environment %{env} and %{pcs}") % { :env => env, :pcs => pcs.to_sentence }
    else
      pretty_print(pcs.is_a?(Hash) ? pcs.keys : pcs)
    end
  end

  def import_proxy_select hash
    select_action_button( _('Import'),
      SmartProxy.puppet_proxies.map do |proxy|
        display_link_if_authorized(_("Import changes from %s") % proxy.name, hash.merge(:proxy => proxy), :class=>'btn')
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
      link_to key,{}, {:remote => true, :rel => "popover", :data => {"content" => hash[key].sort.join('<br>').html_safe, "original-title" => key}}
    end.to_sentence.html_safe

  end

end
