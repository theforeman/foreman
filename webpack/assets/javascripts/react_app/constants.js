import { getManualURL } from './common/helpers';

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
