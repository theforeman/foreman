module KeyPairsHelper
  def key_pair_status_icon(key_pair)
    if key_pair.active
      icon_text('ok', '', {kind: 'pficon', class: 'center', title: _('Active key')})
    elsif key_pair.used_elsewhere
      icon_text('ok', '', {kind: 'pficon', class: 'center warn',
                           title: _('Key used with other compute resource')})
    else
      icon_text('circle-o', '', {kind: 'fa', class: 'center', title: _('Key not connected to any compute resource')})
    end
  end
end
