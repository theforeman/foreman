import { getControllerSearchProps } from '../../constants';

export const SETTINGS_PAGE_DATA_RESOLVED = 'SETTINGS_PAGE_DATA_RESOLVED';
export const SETTINGS_PAGE_DATA_FAILED = 'SETTINGS_PAGE_DATA_FAILED';
export const SETTINGS_PAGE_HIDE_LOADING = 'SETTINGS_PAGE_HIDE_LOADING';
export const SETTINGS_PAGE_SHOW_LOADING = 'SETTINGS_PAGE_SHOW_LOADING';
export const SETTINGS_PAGE_CLEAR_ERROR = 'SETTINGS_PAGE_CLEAR_ERROR';

export const SETTINGS_API_PATH =
  '/settings/all_settings?include_permissions=true';
export const SETTINGS_PATH = '/settings';
export const SETTING_UPDATE_PATH = '/api/settings/:id';
export const SETTINGS_MODAL = 'SETTINGS_MODAL';

export const SETTINGS_SEARCH_PROPS = getControllerSearchProps('settings');
