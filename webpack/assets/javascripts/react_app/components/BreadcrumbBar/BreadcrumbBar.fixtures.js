export const mockBreadcrumbItemOnClick = jest.fn();

export const breadcrumbItems = {
  items: [
    {
      caption: 'root',
      url: '/some-url',
    },
    {
      caption: 'child with onClick',
      onClick: mockBreadcrumbItemOnClick,
    },
    {
      caption: 'active child',
    },
  ],
};

export const breadcrumbTitleItems = {
  items: [
    {
      caption: 'title',
    },
  ],
};

export const breadcrumbsWithReplacementTitle = {
  titleReplacement: 'override title',
  items: [
    {
      caption: 'root',
      url: '/some-url',
    },
    {
      caption: 'active child',
    },
  ],
};

export const resource = {
  resourceUrl: 'some/url',
  nameField: 'name',
  switcherItemUrl: 'some/url/:id',
};

export const resourceWithNestedFields = {
  resourceUrl: 'some/url',
  nameField: 'user.name',
  switcherItemUrl: 'some/url/:id',
};

export const resourceList = [
  { id: '1', name: 'Host 1', url: '#' },
  { id: '2', name: 'Host 2', url: '#' },
  { id: '3', name: 'Host 3 with a very long name', url: '#' },
  {
    id: '4',
    name: 'Host 4',
    url: undefined,
    onClick: jest.fn(),
  },
  {
    id: '5',
    name: 'Host 5',
    url: '#',
    onClick: undefined,
  },
];

export const serverResourceListResponse = {
  data: {
    page: 1,
    subtotal: 3,
    per_page: 2,
    results: [
      { id: '1', name: 'name-1' },
      { id: '2', name: 'name-2' },
      { id: '3', name: 'name-3' },
    ],
  },
};

export const serverResourceListWithNestedFieldsResponse = {
  data: {
    page: 1,
    subtotal: 3,
    per_page: 2,
    results: [
      { id: '1', name: 'name-1', user: { name: 'username-1' } },
      { id: '2', name: 'name-2', user: { name: 'username-2' } },
      { id: '3', name: 'name-3', user: { name: 'username-3' } },
    ],
  },
};

export const breadcrumbSwitcherLoading = {
  loading: true,
  resources: [],
};

export const breadcrumbSwitcherLoaded = {
  loading: false,
  resources: resourceList,
};

export const breadcrumbSwitcherLoadedWithPagination = {
  ...breadcrumbSwitcherLoaded,
  currentPage: 2,
  totalPages: 3,
};

export const breadcrumbSwitcherLoadedWithSearchQuery = {
  ...breadcrumbSwitcherLoaded,
  searchValue: 'Host',
};

export const breadcrumbBar = {
  resource,
  breadcrumbItems: breadcrumbItems.items,
  isSwitchable: false,
};

export const breadcrumbBarSwithcable = {
  resource,
  breadcrumbItems: breadcrumbItems.items,
  isSwitchable: true,
  searchQuery: 'some value',
  searchDebounceTimeout: 0,
};
