module PowerManager
  REAL_ACTIONS = [N_('on'), N_('stop'), N_('shutdown'), N_('reset'), N_('mgmt_warm_reset'), N_('mgmt_cold_reset')]
  SUPPORTED_ACTIONS = REAL_ACTIONS + [N_('status'), N_('ready?')]
end
