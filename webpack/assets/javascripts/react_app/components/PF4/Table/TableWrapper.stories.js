import React, { useState, useEffect } from 'react';
import { Provider } from 'react-redux';
import { TableVariant } from '@patternfly/react-table';
import TableWrapper from './TableWrapper';
import ContextFeatures from '../../Pagination/Context.fixtures';
import { getForemanContext } from '../../../Root/Context/ForemanContext';
import { STATUS } from '../../../constants';
import Story from '../../../../../../stories/components/Story';
import { mockRequest } from '../../../mockRequests';
import store from '../../../redux';

const ForemanContext = getForemanContext();

export default {
  title: 'Components|PF4/TableWrapper',
  decorators: [
    StoryFn => (
      <ForemanContext.Provider value={ContextFeatures}>
        <StoryFn />
      </ForemanContext.Provider>
    ),
  ],
};

const path = window.location.protocol + '//' + window.location.hostname;
window.URL_PREFIX = path;
const autocompleteEndpoint = '/sandwiches/auto_complete_search';

const initializeMocks = () => {
  mockRequest({
    url: `${path}/api/v2/settings/autosearch_delay`,
    response: { value: 500 },
  });

  mockRequest({
    url: `${path}/api/v2/settings/autosearch_while_typing`,
    response: { value: true },
  });

  mockRequest({
    url: `${path}${autocompleteEndpoint}`,
    response: [{ label: ' bread ' }],
  });
};

// Patternfly 4 column/cell header format
const columnHeaders = [__('bread'), __('protein'), __('cheese')];

// Empty content messages
const emptyContentTitle = __("You currently don't have any sandwiches");
const emptyContentBody = __('Please add some sandwiches.'); // needs link
const emptySearchTitle = __('No matching sandwiches found');
const emptySearchBody = __('Try changing your search settings.');

export const defaultStory = () => {
  initializeMocks();
  const fakeMetadata = {
    total: 3,
    subtotal: 3,
    page: 1,
    per_page: 20,
    search: '',
  };
  const sandwiches = [
    { bread: 'rye', protein: 'pastrami', cheese: 'swiss' },
    { bread: 'wheat', protein: 'ham', cheese: 'american' },
    { bread: 'focaccia', protein: 'tofu', cheese: 'havarti' },
  ];

  // Typically handled by API middleware
  const sandwichApiCall = (params = {}) => {
    const { search } = params;
    setStatus(STATUS.PENDING);

    setTimeout(() => {
      setStatus(STATUS.RESOLVED);
      const filteredSandwiches = search
        ? sandwiches.filter(s => s.bread.includes(search))
        : sandwiches;
      setMetadata({ ...fakeMetadata, subtotal: filteredSandwiches.length });
      setResponse({ ...fakeMetadata, results: filteredSandwiches });
    }, 1000);
  };

  // Handling state for table, API response, search, and metadata
  const [rows, setRows] = useState([]);
  const [response, setResponse] = useState({ results: [] });
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const [status, setStatus] = useState(STATUS.PENDING);

  // Listen for API response and build rows according to patternfly 4 format
  useEffect(() => {
    const newRows = response.results.map(sandwich => {
      const { bread, protein, cheese } = sandwich;
      return { cells: [bread, protein, cheese] };
    });
    setRows(newRows);
  }, [response]);

  return (
    <Provider store={store}>
      <Story>
        <TableWrapper
          {...{
            rows,
            metadata,
            emptyContentTitle,
            emptyContentBody,
            emptySearchTitle,
            emptySearchBody,
            searchQuery,
            updateSearchQuery,
            status,
          }}
          cells={columnHeaders}
          variant={TableVariant.compact}
          autocompleteEndpoint={autocompleteEndpoint}
          fetchItems={params => sandwichApiCall(params)}
        />
      </Story>
    </Provider>
  );
};

export const emptyState = () => {
  initializeMocks();
  const [searchQuery, updateSearchQuery] = useState('');

  return (
    <Provider store={store}>
      <Story>
        <TableWrapper
          {...{
            emptyContentTitle,
            emptyContentBody,
            emptySearchTitle,
            emptySearchBody,
            searchQuery,
            updateSearchQuery,
          }}
          status={STATUS.RESOLVED}
          metadata={{}}
          rows={[]}
          cells={columnHeaders}
          variant={TableVariant.compact}
          autocompleteEndpoint={autocompleteEndpoint}
          fetchItems={() => {}}
        />
      </Story>
    </Provider>
  );
}

export const emptySearch = () => {
  initializeMocks();
  // Setting a fixed search value. It won't show in the search bar, this function is controlled by the search bar.
  const [searchQuery, updateSearchQuery] = useState('foo');

  return (
    <Provider store={store}>
      <Story>
        <TableWrapper
          {...{
            emptyContentTitle,
            emptyContentBody,
            emptySearchTitle,
            emptySearchBody,
            searchQuery,
            updateSearchQuery,
          }}
          status={STATUS.RESOLVED}
          metadata={{}}
          rows={[]}
          cells={columnHeaders}
          variant={TableVariant.compact}
          autocompleteEndpoint={autocompleteEndpoint}
          fetchItems={() => {}}
        />
      </Story>
    </Provider>
  );
}
