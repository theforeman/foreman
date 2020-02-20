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

const appMetadataState = {
  app: {
    metadata: {
      version: '2.1',
    },
  },
};

export const state = {
  auditsPage: {
    data: {
      audits: AuditsProps.audits,
      message: '',
      isLoading: false,
      hasError: false,
      itemCount: AuditsProps.audits.length,
    },
    query: {
      page: 1,
      perPage: 20,
      searchQuery: '',
    },
  },
  ...appMetadataState,
};

export const getStateWithDocumentationUrl = () => {
  const modifiedState = { ...state };
  modifiedState.auditsPage.data.documentationUrl = '/test';
  return modifiedState;
};

export const auditsPageProps = {
  perPageOptions: [5, 10, 20, 50],
  documentationUrl: '/url',
  searchProps: SearchBarProps,
  searchable: true,
  location: {},
  initializeAudits: noop,
  fetchAndPush: noop,
  isLoading: false,
  hasData: true,
  searchQuery: 'search',
  version: '1.23',
};
