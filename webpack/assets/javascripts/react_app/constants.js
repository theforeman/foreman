import { getManualURL } from './common/helpers';

export const MS_PER_SECOND = 1000;
export const PERCENT_MULTIPLIER = 100;
export const BYTES_PER_KB = 1024;

export const HTTP_STATUS_CODES = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  UNPROCESSABLE_ENTITY: 422,
  INTERNAL_SERVER_ERROR: 500,
};

export const STATUS = {
  PENDING: 'PENDING',
  RESOLVED: 'RESOLVED',
  ERROR: 'ERROR',
};

export const getControllerSearchProps = (
  controller,
  id = `searchBar-${controller}`,
  canCreate = true,
  apiParams = {}
) => ({
  controller,
  autocomplete: {
    id,
    searchQuery: '',
    url: `${controller}/auto_complete_search`,
    apiParams: apiParams,
    useKeyShortcuts: true,
  },
  bookmarks: {
    id,
    url: '/api/bookmarks',
    canCreate,
    documentationUrl: getManualURL('4.1.5Searching'),
  },
});
