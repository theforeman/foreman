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
  loadingBool: true,
};

export const state = {
  auditsPage: {
    audits: AuditsProps.audits,
    page: 1,
    perPage: 20,
    itemCount: 0,
    showMessage: false,
    isLoading: false,
    isFetchingNext: false,
    isFetchingPrev: false,
    message: {},
    searchQuery: '',
  },
};

export const auditsPageProps = {
  data: {
    perPageOptions: [5, 10, 20, 50],
    docURL: '/url',
    searchProps: SearchBarProps,
    searchable: true,
  },
  ...state.auditsPage,
  location: {},
  initializeAudits: noop,
  auditSearch: noop,
  changePage: noop,
  changePerPage: noop,
};
