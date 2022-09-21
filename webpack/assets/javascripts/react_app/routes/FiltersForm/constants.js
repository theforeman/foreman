import { getControllerSearchProps } from '../../constants';

export const MODELS_PAGE_DATA_RESOLVED = 'MODELS_PAGE_DATA_RESOLVED';
export const MODELS_PAGE_DATA_FAILED = 'MODELS_PAGE_DATA_FAILED';
export const MODELS_PAGE_HIDE_LOADING = 'MODELS_PAGE_HIDE_LOADING';
export const MODELS_PAGE_SHOW_LOADING = 'MODELS_PAGE_SHOW_LOADING';
export const MODELS_PAGE_CLEAR_ERROR = 'MODELS_PAGE_CLEAR_ERROR';

export const MODELS_SEARCH_PROPS = getControllerSearchProps('models');
export const MODELS_API_PATH = '/api/models?include_permissions=true';
export const MODEL_DELETE_MODAL_ID = 'modelDeleteModal';
export const API_REQUEST_KEY = 'MODELS';

export const FILTERS_PATH_NEW = '/filters/new';
export const FILTERS_PATH_EDIT = '/filters/:id/edit';
