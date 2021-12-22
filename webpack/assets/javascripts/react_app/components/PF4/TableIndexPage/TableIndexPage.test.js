import React from 'react';
import { Provider } from 'react-redux';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import { fireEvent, screen, render, act } from '@testing-library/react';
// import * as api from 'foremanReact/redux/API';
// import * as routerSelectors from 'foremanReact/routes/RouterSelector';
import TableIndexPage from './TableIndexPage';
import { breadcrumbBar } from '../../../components/BreadcrumbBar/BreadcrumbBar.fixtures';
import '@testing-library/jest-dom';

const controller = 'testController';
const mockStore = configureMockStore([thunk]);
const apiKey = 'API_TEST';
const store = mockStore({
  API: {
    [apiKey]: {
      response: {
        items: ['item1', 'item2'],
        can_create: true,
      },
    },
  },
  autocomplete: { searchBar: { url: '/test/', searchQuery: 'name=test' } },
  foremanModals: {
    modal2: { isOpen: false },
  },
  breadcrumbBar: { resourceSwitcherItems: [{ name: 'a', id: '1' }] },
});

const props = {
  apiUrl: '/api/test',
  apiOptions: { key: apiKey },
  header: 'Test Title',
  breadcrumbOptions: breadcrumbBar,
  beforeToolbarComponent: <span>I am before the toolbar</span>,
  controller,
  searchable: true,
  exportable: true,
  creatable: true,
  hasHelpPage: true,
  children: <div>Content</div>,
  customActionButtons: [
    {
      title: 'Custom Action',
      action: { href: '/custom' },
    },
  ],
  cutsomToolbarItems: <button>Custom button</button>,
};
Object.defineProperty(window, 'location', {
  value: { href: '/test?search=name=test' },
});
describe('TableIndexPage', () => {
  it('All props are shown', async () => {
    render(
      <Provider store={store}>
        <TableIndexPage {...props} />
      </Provider>
    );
    expect(screen.getByText('Create new').closest('a')).toHaveAttribute(
      'href',
      '/test/new'
    );
    await act(async () => {
      fireEvent.click(screen.getByLabelText('toggle action dropdown'));
    });
    expect(screen.getByText('Export').closest('a')).toHaveAttribute(
      'href',
      '/test?search=name%3Dtest&format=csv'
    );
    expect(screen.getByText('Documentation').closest('a')).toHaveAttribute(
      'href',
      '/test/help'
    );
    expect(screen.getByText('Custom Action').closest('a')).toHaveAttribute(
      'href',
      '/custom'
    );

    expect(screen.queryAllByText('I am before the toolbar')).toHaveLength(1);
    
    expect(screen.getByDisplayValue('name=test')).toBeInTheDocument();
    expect(screen.queryAllByText('Test Title')).toHaveLength(1);
    expect(screen.queryAllByText('Custom button')).toHaveLength(1);
  });
});
