// API
export const STATUS = {
  PENDING: 'PENDING',
  RESOLVED: 'RESOLVED',
  ERROR: 'ERROR',
};

// Documentation
export const FOREMAN_VERSION = '1.22';
export const DOCUMENTATION_URL = `https://theforeman.org/manuals/${FOREMAN_VERSION}/index.html`;

// Pagination
export const PAGE_OPTIONS = [5, 10, 25, 50];

// Search
export const getControllerSearchProps = (controller, canCreate = true) => ({
  controller,
  autocomplete: {
    searchQuery: '',
    url: `${controller}/auto_complete_search`,
  },
  bookmarks: {
    url: '/api/bookmarks',
    canCreate,
    documentationUrl: `${DOCUMENTATION_URL}#4.1.5Searching`,
  },
});
