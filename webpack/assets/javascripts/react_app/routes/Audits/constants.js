import { getControllerSearchProps } from '../../constants';

export const AUDITS_PAGE_DATA_RESOLVED = 'AUDITS_PAGE_DATA_RESOLVED';
export const AUDITS_PAGE_DATA_FAILED = 'AUDITS_PAGE_DATA_FAILED';
export const AUDITS_PAGE_HIDE_LOADING = 'AUDITS_PAGE_HIDE_LOADING';
export const AUDITS_PAGE_SHOW_LOADING = 'AUDITS_PAGE_SHOW_LOADING';
export const AUDITS_PAGE_UPDATE_QUERY = 'AUDITS_PAGE_UPDATE_QUERY';
export const AUDITS_PAGE_CLEAR_ERROR = 'AUDITS_PAGE_CLEAR_ERROR';

export const AUDITS_PATH = '/audits';
export const AUDITS_SEARCH_PROPS = getControllerSearchProps('audits');
