module PuppetcaHelper
  STATES = [N_('pending'), N_('valid'), N_('revoked')]
  CA_ICONS = { 'valid' => 'pficon pficon-ok',
               'pending' => 'pficon pficon-warning-triangle-o',
               'revoked' => 'fa fa-ban' }

  def state_filter
    select_tag "Filter", options_for_select([[_('valid or pending'), _('valid') + '|' + _('pending')]] +
                                            STATES.map { |s| _(s) } +
                                            [[_('all'), '']]),
      :class => "datatable-filter", :id => "puppetca-filter"
  end
end
