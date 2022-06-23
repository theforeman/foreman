import { translate as __ } from '../../../../common/I18n';

export const POWER_REQURST_KEY = 'HOST_TOGGLE_POWER';
export const POWER_REQUEST_OPTIONS = { key: POWER_REQURST_KEY, params: { timeout: 30 } };
export const BASE_POWER_STATES = { off: __('Off'), on: __('On') };
export const BMC_POWER_STATES = { soft: __('Reboot'), cycle: __('Reset') };
export const SUPPORTED_POWER_STATES = {
  ...BASE_POWER_STATES,
  ...BMC_POWER_STATES,
};
