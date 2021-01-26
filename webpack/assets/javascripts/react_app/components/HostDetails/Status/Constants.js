import { translate as __ } from '../../../common/I18n';

export const HOST_STATUSES_KEY = 'HOST_STATUSES';
export const CLEAR_STATUS_KEY = 'CLEAR_STATUS';
export const HOST_STATUSES_OPTIONS = { key: HOST_STATUSES_KEY };

export const ALL_STATUS_STATE = 4;
export const NA_STATUS_STATE = 3;
export const ERROR_STATUS_STATE = 2;
export const WARNING_STATUS_STATE = 1;
export const OK_STATUS_STATE = 0;

export const SUPPORTED_STATUSES = [
  { label: __('OK statuses'), status: OK_STATUS_STATE },
  { label: __('Warning statuses'), status: WARNING_STATUS_STATE },
  { label: __('Error statuses'), status: ERROR_STATUS_STATE },
  { label: __('N/A statuses'), status: NA_STATUS_STATE },
];
