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

  test('shows delete modal when delete button is clicked', () => {
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

    fireEvent.click(screen.getByLabelText('Actions'));
    fireEvent.click(screen.getByText('Delete'));
    expect(
      screen.getByText('You are about to delete John Doe. Are you sure?')
    ).toBeInTheDocument();
    fireEvent.click(screen.getByText('Delete'));
  });

  test('disables delete button when item cannot be deleted', () => {
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
    fireEvent.click(screen.getByLabelText('Actions'));
    expect(screen.getByText('Delete')).toHaveClass('pf-m-disabled');
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
    expect(screen.queryAllByText('Actions')).toHaveLength(0);
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
});
