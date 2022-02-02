module PowerManager
  REAL_ACTIONS = [N_('start'), N_('stop'), N_('poweroff'), N_('reboot'), N_('reset')]
  SUPPORTED_ACTIONS = REAL_ACTIONS + [N_('state'), N_('status'), N_('ready?')]
end
