import React from 'react';
import {
  render,
  fireEvent,
  screen,
  act,
  waitFor,
} from '@testing-library/react';
import SearchBar from '.';
import { Provider } from 'react-redux';
import store from '../../redux';
import {
  SearchBarProps,
  mockModelsEmptyAutocomplete,
  mockModelsHardwareAutocomplete,
  mockNotRecognizedResponse,
} from './SearchBar.fixtures';

jest.mock('../../redux/API/API', () => ({
  get: async (url, header, params) => {
    if (url === 'model/auto_complete_search') {
      if (!params?.search) {
        return { data: mockModelsEmptyAutocomplete };
      }
      if (params?.search === 'hardware_model  = ') {
        return { data: mockModelsHardwareAutocomplete };
      }
      if (params?.search === 'wrong = nope') {
        return { data: mockNotRecognizedResponse };
      }
    }
    if (url === '/api/bookmarks?search=controller%3Dmodels&per_page=all') {
      return {
        data: {
          total: 12,
          subtotal: 1,
          page: 1,
          per_page: 12,
          search: 'controller=models',
          sort: {
            by: null,
            order: null,
          },
          results: [
            {
              name: 'name = a',
              controller: 'models',
              query: 'name = a',
              public: true,
              id: 7,
              owner_id: 16,
              owner_type: 'User',
            },
          ],
        },
      };
    }
  },
}));

describe('SearchBar', () => {
  it('edit', async () => {
    render(
      <Provider store={store}>
        <SearchBar {...SearchBarProps} />
      </Provider>
    );

    expect(screen.queryAllByText('hardware_model')).toHaveLength(0);
    expect(screen.queryAllByText('vendor_class')).toHaveLength(0);
    await act(async () => {
      fireEvent.click(screen.getByLabelText('Search input'));
    });

    await waitFor(() => screen.getByText('hardware_model'));
    expect(screen.queryAllByText('vendor_class')).toHaveLength(1);
    await act(async () => {
      screen.getByLabelText('Search input').focus();
      fireEvent.change(screen.getByLabelText('Search input'), {
        target: { value: 'hardware_model  = ' },
      });
    });
    await waitFor(() => screen.getByText('hardware_model = test'));
    expect(screen.queryAllByText('hardware_model =')).toHaveLength(1);
    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await act(async () => {
      fireEvent.click(screen.getByText('Bookmark this search'));
    });
    expect(screen.queryAllByDisplayValue('hardware_model =')).toHaveLength(2);
  });
});
