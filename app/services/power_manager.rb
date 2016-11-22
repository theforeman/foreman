module PowerManager
  REAL_ACTIONS = [N_('start'), N_('stop'), N_('poweroff'), N_('reboot'), N_('reset'), N_('soft'), N_('cycle')]
  SUPPORTED_ACTIONS = REAL_ACTIONS + [N_('state'), N_('on'), N_('off'), N_('status'), N_('ready?')]
end
