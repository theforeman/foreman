module PuppetcaHelper
  STATES = [N_('pending'), N_('valid'), N_('revoked')]
  CA_ICONS = { 'valid' => 'pficon pficon-ok',
               'pending' => 'pficon pficon-warning-triangle-o',
               'revoked' => 'fa fa-ban' }

  def state_filter
    select_tag "Filter", options_for_select([[_('valid or pending'), _('valid')+'|'+_('pending')]] +
                                            STATES.map{|s| _(s)} +
                                            [[_('all'),'']]),
               :class => "datatable-filter", :id => "puppetca-filter"
  end

  def time_column(time, opts = {})
    return _("N/A") if time.blank?
    opts[:tense] ||= :past

    if opts[:tense] == :future
      _("in %s") % (time_ago_in_words time)
    elsif opts[:tense] == :past
      _("%s ago") % (time_ago_in_words time)
    else
      time_ago_in_words time
    end
  end
end
