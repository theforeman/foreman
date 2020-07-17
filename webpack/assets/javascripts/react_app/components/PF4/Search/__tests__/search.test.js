import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from '../../../../react-testing-lib-wrapper.js';
import nock, { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../nockWrapper';
import Search from '../../Search';
import '@testing-library/jest-dom/extend-expect'

const endpoint = '/fake_endpoint';
const searchButtonLabel = 'search button';
const props = {
  onSearch: jest.fn(),
  getAutoCompleteParams: search => ({
    params: { organization_id: 1, search },
    endpoint,
  }),
  settings: {
    autoSearchEnabled: true
  }
};

afterEach(() => {
  nock.cleanAll();
});

test('Autocomplete shows on input', async (done) => {
  const suggestion = 'suggestedQuery';
  const response = [
    {
      completed: '', part: ` ${suggestion} `, label: ` ${suggestion} `, category: '',
    },
  ];
  const query = { organization_id: 1, search: 'foo' };
  const initialScope = mockAutocomplete(nockInstance, endpoint, { ...query, search: '' }, []);
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint, query, response);

  const { getByLabelText, getByText, queryByText } = renderWithRedux(<Search {...props} />);

  expect(queryByText(`${suggestion}`)).not.toBeInTheDocument();

  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: 'foo' } });

  await patientlyWaitFor(() => expect(getByText(`${suggestion}`)).toBeInTheDocument());

  assertNockRequest(initialScope);
  assertNockRequest(autocompleteScope, done);
});

test('autosearch turned on does not show patternfly 4 search button', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint);

  const { queryByLabelText } = renderWithRedux(<Search {...props} />);

  await patientlyWaitFor(() => expect(queryByLabelText(searchButtonLabel)).not.toBeInTheDocument());

  assertNockRequest(autocompleteScope, done);
});

test('autosearch turned off does show patternfly 4 search button', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint);

  const { getByLabelText } = renderWithRedux(<Search {...props} settings={{ autoSearchEnabled: false }} />);

  // Using patientlyWaitFor as the autoSearch setting defaults to true,
  // it won't be changed until http call
  await patientlyWaitFor(() => expect(getByLabelText(searchButtonLabel)).toBeInTheDocument());

  assertNockRequest(autocompleteScope, done);
});

test('search function is called when search is typed into with autosearch', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint, true, [], 2);
  const mockSearch = jest.fn();

  const { getByLabelText } = renderWithRedux(<Search {...{ ...props, onSearch: mockSearch }} />);
  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: 'foo' } });
  await patientlyWaitFor(() => expect(mockSearch.mock.calls).toHaveLength(1));

  assertNockRequest(autocompleteScope, done);
});

test('search function is called by clicking search button without autosearch', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, endpoint, true, [], 2);
  const mockSearch = jest.fn();

  const { getByLabelText } = renderWithRedux(
    <Search {...{ ...props, onSearch: mockSearch, settings: { autoSearchEnabled: false } }} />
  );

  fireEvent.change(getByLabelText(/text input for search/i), { target: { value: 'foo' } });
  let searchButton;
  await patientlyWaitFor(() => {
    searchButton = getByLabelText(searchButtonLabel);
    expect(searchButton).toBeInTheDocument();
  });
  searchButton.click();
  expect(mockSearch.mock.calls).toHaveLength(1);

  assertNockRequest(autocompleteScope, done);
});
