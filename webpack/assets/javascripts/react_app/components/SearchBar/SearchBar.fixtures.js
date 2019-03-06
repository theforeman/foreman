export const SearchBarProps = {
  data: {
    autocomplete: {
      searchQuery: null,
      url: 'model/auto_complete_search',
    },
    bookmarks: {
      url: '/api/bookmarks',
      canCreate: true,
      documentationUrl: '/doc/url',
    },
    controller: 'models',
  },
};

export const mockResults = [
  { label: 'name', category: '' },
  { label: 'info', category: '' },
  { label: ' not', category: 'Operators' },
  { label: ' has', category: 'Operators' },
];
