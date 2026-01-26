import React from 'react';
import { Provider } from 'react-redux';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import { fireEvent, screen, render, act } from '@testing-library/react';
import '@testing-library/jest-dom';

import { Table } from './Table';

const mockStore = configureMockStore([thunk]);
const store = mockStore({});
const columns = {
  name: { title: 'Name' },
  email: { title: 'Email' },
  role: { title: 'Role' },
};

const results = [
  { id: 1, name: 'John Doe', email: 'johndoe@example.com', role: 'Admin' },
  { id: 2, name: 'Jane Smith', email: 'janesmith@example.com', role: 'User' },
];

const setParams = jest.fn();
const refreshData = jest.fn();

describe('Table', () => {
  test('renders column names and result data', () => {
    render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={results}
          url="/users"
          isPending={false}
        />
      </Provider>
    );

    // Check that column names are displayed
    expect(screen.getByText('Name')).toBeInTheDocument();
    expect(screen.getByText('Email')).toBeInTheDocument();
    expect(screen.getByText('Role')).toBeInTheDocument();

    // Check that result data is displayed
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('johndoe@example.com')).toBeInTheDocument();
    expect(screen.getByText('Admin')).toBeInTheDocument();
    expect(screen.getByText('Jane Smith')).toBeInTheDocument();
    expect(screen.getByText('janesmith@example.com')).toBeInTheDocument();
    expect(screen.getByText('User')).toBeInTheDocument();
  });

  test('calls setParams with sort order when column header is clicked', async () => {
    render(
      <Provider store={store}>
        <Table
          columns={{ ...columns, name: { ...columns.name, isSorted: true } }}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={results}
          url="/users"
          isPending={false}
        />
      </Provider>
    );
    fireEvent.click(screen.getByRole('button', { name: 'Name' }));
    expect(setParams).toHaveBeenCalledWith({
      order: 'name desc',
      page: 1,
      perPage: 10,
    });
    fireEvent.click(screen.getByRole('button', { name: 'Name' }));
    expect(setParams).toHaveBeenCalledWith({
      order: 'name asc',
      page: 1,
      perPage: 10,
    });
  });

  test('shows delete modal when delete button is clicked', async () => {
    const onDeleteClick = jest.fn();
    const resultWithDeleteButton = { ...results[0], can_delete: true };

    render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={[resultWithDeleteButton]}
          isDeleteable={true}
          onDeleteClick={onDeleteClick}
          url="/users"
          isPending={false}
        />
      </Provider>
    );

    fireEvent.click(screen.getByLabelText('Kebab toggle'));
    fireEvent.click(screen.getByText('Delete'));
    expect(
      screen.getByText('You are about to delete John Doe. Are you sure?')
    ).toBeInTheDocument();
    fireEvent.click(screen.getByText('Delete'));
    await act(async () => {
      jest.advanceTimersByTime(1000); // to handle pf4 table actions popover
    });
  });

  test('disables delete button when item cannot be deleted', async () => {
    const resultWithDeleteButton = { ...results[0], can_delete: false };

    render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={[resultWithDeleteButton]}
          isDeleteable={true}
          url="/users"
          isPending={false}
        />
      </Provider>
    );
    fireEvent.click(screen.getByLabelText('Kebab toggle'));
    expect(screen.getByRole('none', {description: 'Delete'})).toHaveClass('pf-m-aria-disabled');
    await act(async () => {
      jest.advanceTimersByTime(1000); // to handle pf4 table actions popover
    });
  });

  test('no actions button when there are no actions', () => {
    const resultWithDeleteButton = { ...results[0], can_delete: true };

    render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={[resultWithDeleteButton]}
          isDeleteable={true}
          url="/users"
          isPending={false}
        />
      </Provider>
    );
    expect(screen.queryAllByText('Kebab toggle')).toHaveLength(0);
  });

  test('show error and not the table on error', () => {
    render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={results}
          errorMessage="Error test"
          isDeleteable={true}
          url="/users"
          isPending={false}
        />
      </Provider>
    );
    expect(screen.queryAllByText('John')).toHaveLength(0);
    expect(screen.queryAllByText('items')).toHaveLength(0);
    expect(screen.queryAllByText('Error test')).toHaveLength(1);
  });
  test('show empty state', () => {
    render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={[]}
          errorMessage="Empty test"
          isDeleteable={true}
          url="/users"
          isPending={false}
        />
      </Provider>
    );
    expect(screen.queryAllByText('items')).toHaveLength(0);
    expect(screen.queryAllByText('Empty test')).toHaveLength(1);
    expect(screen.queryAllByText('Loading...')).toHaveLength(0);
  });
  test('show empty state while loading', () => {
    render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={[]}
          isDeleteable={true}
          url="/users"
          isPending={true}
        />
      </Provider>
    );
    expect(screen.queryAllByText('items')).toHaveLength(0);
    expect(screen.queryAllByText('No Results')).toHaveLength(0);
    expect(screen.queryAllByText('Loading...')).toHaveLength(1);
  });

  test('uses result.id as React key for table rows', () => {
    const { container } = render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={results}
          url="/users"
          isPending={false}
        />
      </Provider>
    );

    // Find all table rows (excluding header row)
    const rows = container.querySelectorAll('tbody tr');
    expect(rows).toHaveLength(2);

    // Verify first row uses result.id as key
    expect(rows[0]).toHaveAttribute('data-ouia-component-id', 'table-row-1');

    // Verify second row uses result.id as key
    expect(rows[1]).toHaveAttribute('data-ouia-component-id', 'table-row-2');
  });

  test('uses idColumn prop for React key when provided', () => {
    const customResults = [
      { custom_id: 'abc-123', name: 'John Doe', email: 'johndoe@example.com', role: 'Admin' },
      { custom_id: 'xyz-456', name: 'Jane Smith', email: 'janesmith@example.com', role: 'User' },
    ];

    const { container } = render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={customResults}
          idColumn="custom_id"
          url="/users"
          isPending={false}
        />
      </Provider>
    );

    const rows = container.querySelectorAll('tbody tr');
    expect(rows).toHaveLength(2);

    // Verify rows use custom_id as key
    expect(rows[0]).toHaveAttribute('data-ouia-component-id', 'table-row-abc-123');
    expect(rows[1]).toHaveAttribute('data-ouia-component-id', 'table-row-xyz-456');
  });

  test('keys remain stable when results are reordered', () => {
    const sortedResults = [
      { id: 2, name: 'Jane Smith', email: 'janesmith@example.com', role: 'User' },
      { id: 1, name: 'John Doe', email: 'johndoe@example.com', role: 'Admin' },
    ];

    const { container, rerender } = render(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: '' }}
          setParams={setParams}
          refreshData={refreshData}
          results={results}
          url="/users"
          isPending={false}
        />
      </Provider>
    );

    // Check initial order
    let rows = container.querySelectorAll('tbody tr');
    expect(rows[0]).toHaveAttribute('data-ouia-component-id', 'table-row-1');
    expect(rows[1]).toHaveAttribute('data-ouia-component-id', 'table-row-2');

    // Re-render with sorted results
    rerender(
      <Provider store={store}>
        <Table
          columns={columns}
          params={{ page: 1, perPage: 10, order: 'name desc' }}
          setParams={setParams}
          refreshData={refreshData}
          results={sortedResults}
          url="/users"
          isPending={false}
        />
      </Provider>
    );

    // After sort, keys should follow the data
    rows = container.querySelectorAll('tbody tr');
    expect(rows[0]).toHaveAttribute('data-ouia-component-id', 'table-row-2');
    expect(rows[1]).toHaveAttribute('data-ouia-component-id', 'table-row-1');
  });
});
