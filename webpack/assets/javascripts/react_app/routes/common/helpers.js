import { foremanUrl, urlBuilder } from '../../common/urlHelpers';

export const getControllerSearchProps = (
  controller,
  id = 'searchBar',
  canCreate = true
) => ({
  controller,
  autocomplete: {
    id,
    searchQuery: '',
    url: urlBuilder(controller, 'auto_complete_search'),
    useKeyShortcuts: true,
  },
  bookmarks: {
    url: foremanUrl('/api/bookmarks'),
    canCreate,
    documentationUrl: `4.1.5Searching`,
  },
});
