export const SearchBarProps = {
  data: {
    autocomplete: {
      apiParams: {},
      searchQuery: null,
      url: 'model/auto_complete_search',
      id: 'searchBar',
      useKeyShortcuts: true,
    },
    bookmarks: {
      id: 'searchBar',
      url: '/api/bookmarks',
      canCreate: true,
      documentationUrl: '/doc/url',
    },
    controller: 'models',
  },
};

export const mockModelsEmptyAutocomplete = [
  {
    completed: '',
    part: ' hardware_model ',
    label: ' hardware_model ',
    category: '',
  },
  { completed: '', part: ' info ', label: ' info ', category: '' },
  { completed: '', part: ' name ', label: ' name ', category: '' },
  {
    completed: '',
    part: ' vendor_class ',
    label: ' vendor_class ',
    category: '',
  },
  {
    completed: '',
    part: ' not',
    label: ' not',
    category: '»Operators«',
  },
  {
    completed: '',
    part: ' has',
    label: ' has',
    category: '»Operators«',
  },
];

export const mockModelsHardwareAutocomplete = [
  {
    completed: '',
    part: 'hardware_model = ',
    label: 'hardware_model = ',
    category: '',
  },
  {
    completed: '',
    part: 'hardware_model = test',
    label: 'hardware_model = test',
    category: '',
  },
];

export const mockNotRecognizedResponse = [
  { error: "Field 'wrong' not recognized for searching!" },
];
