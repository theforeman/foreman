import React, { useState, useEffect } from 'react';
import { STATUS } from '../../../../constants';
import API from '../../../../redux/API/API';
import { renderWithRedux, patientlyWaitFor } from '../../../../react-testing-lib-wrapper.js';
import TableWrapper from "../TableWrapper";
import '@testing-library/jest-dom/extend-expect'

jest.mock('../../../../redux/API/API'); // Using redux/API/API so the other redux/API/* functions don't get mocked

beforeEach(() => {
  const autocompleteEndpoint = '/sandwiches/auto_complete_search';
  API.get.mockImplementation((url) => {
    if (url === autocompleteEndpoint) {
      return Promise.resolve({ data: [{ label: ' bread ' }] });
    }
  })
});

const sandwiches = [
  { bread: 'rye', protein: 'pastrami', cheese: 'swiss' },
  { bread: 'wheat', protein: 'ham', cheese: 'american' },
  { bread: 'focaccia', protein: 'tofu', cheese: 'havarti' },
]

// Creating a dummy table to test as the hooks need to be initialized in a function
const SandwichTable = (overrideProps = {}) => {
  // Handling state for table, API response, search, and metadata
  const [status, setStatus] = useState(STATUS.PENDING);
  const [rows, setRows] = useState(null);
  const [response, setResponse] = useState({ results: [] });
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const columnHeaders = [ __('bread'), __('protein'), __('cheese') ];
  const emptyContentTitle = __("You currently don't have any sandwiches");
  const emptyContentBody = __('Please add some sandwiches.'); // needs link
  const emptySearchTitle = __('No matching sandwiches found');
  const emptySearchBody = __('Try changing your search settings.')

  // Listen for API response and build rows according to patternfly 4 format
  useEffect(() => {
    const { results } = response;
    const newRows = results.map(sandwich => {
      const { bread, protein, cheese } = sandwich;
      return { cells: [bread, protein, cheese] };
    })
    setMetadata({ total: results.length, subtotal: results.length, page: 1, per_page: 20 });
    setRows(newRows);
    if (results.length > 0) setStatus(STATUS.RESOLVED);
  }, [response])

  // Faking API call
  const sandwichApiCall = () => setTimeout(() => setResponse({ results: sandwiches }), 1000);

  return (
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
      autocompleteEndpoint="/sandwiches/auto_complete_search"
      fetchItems={params => sandwichApiCall(params)}
      { ...overrideProps }
    />
  );
}

test('Can call API, show loading, and display rows on page load', async () => {
  const { queryByLabelText, getByLabelText, getByText } = renderWithRedux(<SandwichTable />, {});

  const loadingLabel = 'loading icon'
  // Loading icon shows first
  expect(getByLabelText(loadingLabel)).toBeInTheDocument();
  // Loading icon disappears
  await patientlyWaitFor(() => expect(queryByLabelText(loadingLabel)).not.toBeInTheDocument());

  // the data is shown in the table
  sandwiches.forEach(({ bread, protein, cheese }) => {
    expect(getByText(bread)).toBeInTheDocument();
    expect(getByText(protein)).toBeInTheDocument();
    expect(getByText(cheese)).toBeInTheDocument();
  })
});