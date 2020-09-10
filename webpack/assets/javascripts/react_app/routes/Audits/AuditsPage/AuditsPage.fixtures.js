import { AuditsProps } from '../../../components/AuditsList/__tests__/AuditsList.fixtures';
import { SearchBarProps } from '../../../components/SearchBar/SearchBar.fixtures';
import { noop } from '../../../common/helpers';

export const responseMock = {
  data: {
    audits: AuditsProps.audits,
    itemCount: AuditsProps.audits.length,
  },
};

export const emptyResponseMock = {
  data: {
    audits: [],
    itemCount: 0,
  },
};

export const getMock = {
  page: 1,
  perPage: 20,
  searchQuery: '',
};

export const state = {
  auditsPage: {
    data: {
      audits: AuditsProps.audits,
      message: '',
      isLoading: false,
      hasError: false,
      hasData: true,
    },
    query: {
      page: 1,
      perPage: 20,
      itemCount: 0,
      searchQuery: '',
    },
  },
};

export const auditsPageProps = {
  searchProps: SearchBarProps,
  searchable: true,
  location: {},
  initializeAudits: noop,
  fetchAndPush: noop,
  isLoading: false,
  hasData: true,
  searchQuery: 'search',
};
