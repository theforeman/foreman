export const POWER_STATES = [
  { value: 'start', label: 'Start' },
  { value: 'stop', label: 'Stop' },
  { value: 'poweroff', label: 'Power Off' },
  { value: 'reboot', label: 'Reboot' },
  { value: 'reset', label: 'Reset' },
  { value: 'soft', label: 'Reboot (Soft)' },
  { value: 'cycle', label: 'Power Cycle' },
];

export const BULK_POWER_STATE_KEY = 'BULK_POWER_STATE_CHANGE';
export const BULK_POWER_STATE_URL = '/api/v2/hosts/bulk/change_power_state';
