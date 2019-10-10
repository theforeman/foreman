import { API_REQUEST_KEY } from '../../constants';

export const pickedQuery = { by: 'default_name', order: 'ASC' };

const searchString = 'name=foo';

const stateSearch = { search: searchString };

const querySearch = { searchQuery: searchString };

export const querySort = {
  sort: {
    by: 'defaultName',
    order: 'ASC',
  },
};

const pageParams = {
  page: 5,
  perPage: 42,
};

const stateParams = {
  ...pageParams,
  ...stateSearch,
  ...querySort,
};

export const resultParams = {
  ...pageParams,
  ...querySearch,
  sort: pickedQuery,
};

export const queryParams = {
  ...pageParams,
  ...querySearch,
  ...querySort,
};

export const stateFactory = state => ({
  API: {
    [API_REQUEST_KEY]: {
      response: {
        ...stateParams,
        ...state,
      },
    },
  },
});

export const propsFactory = (state = {}) => ({
  ...stateParams,
  ...state,
});

export const models = [
  {
    id: 1,
    name: 'my-hw-model',
    canEdit: true,
    canDelete: true,
    hostsCount: 5,
    vendorClass: 'custom',
  },
  {
    id: 2,
    name: 'your-hw-model',
    canEdit: false,
    canDelete: false,
    hostsCount: 4,
    vendorClass: 'B+',
  },
];
