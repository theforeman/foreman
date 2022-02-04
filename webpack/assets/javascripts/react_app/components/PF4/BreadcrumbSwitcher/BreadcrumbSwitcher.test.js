import React from 'react';
import { render, fireEvent, screen, act } from '@testing-library/react';

import BreadcrumbSwitcher from './index';

jest.useFakeTimers();
const props = {
  isOpen: true,
  isLoading: false,
  hasError: false,
  items: [{ name: 'breadcrumb item 3', id: '1' }],
  currentPage: 2,
  total: 30,
  openSwitcher: jest.fn(),
  onHide: jest.fn(),
  onOpen: jest.fn(),
  onSearchChange: jest.fn(),
  onSetPage: jest.fn(),
  onPerPageSelect: jest.fn(),
  perPage: 5,
  searchValue: '',
  onSearchClear: jest.fn(),
  searchDebounceTimeout: 5,
  onResourceClick: jest.fn(),
};

describe('BreadcrumbSwitcher', () => {
  it('items', async () => {
    render(<BreadcrumbSwitcher {...props}/>);
    await act(async () => jest.runAllTimers());
    const item = screen.queryAllByText('breadcrumb item 3');
    expect(item).toHaveLength(1);
  });
  it('no items', async () => {
    render(<BreadcrumbSwitcher {...props} items={[]} />);
    await act(async () => jest.runAllTimers());
    const tooMany = screen.queryAllByText('No results found');
    expect(tooMany).toHaveLength(1);
  });
  it('isLoading', async () => {
    render(<BreadcrumbSwitcher {...props} isLoading />);
    await act(async () => jest.runAllTimers());
    const loading = screen.queryAllByLabelText('loading spinner');
    expect(loading).toHaveLength(1);
  });

  it('change page', async () => {
    render(<BreadcrumbSwitcher {...props} />);
    await act(async () => jest.runAllTimers());
    expect(props.onSetPage.mock.calls).toHaveLength(0);
    await act(async () =>
      fireEvent.click(screen.getByLabelText('Go to next page'))
    );
    expect(props.onSetPage.mock.calls).toHaveLength(1);
    await act(async () =>
      fireEvent.click(screen.getByLabelText('Go to previous page'))
    );
    expect(props.onSetPage.mock.calls).toHaveLength(2);
  });

  it('switcher search', async () => {
    render(<BreadcrumbSwitcher {...props} />);
    await act(async () => jest.runAllTimers());
    expect(props.onSearchChange.mock.calls).toHaveLength(0);
    const search = 'some search';
    await act(async () =>
      fireEvent.change(screen.getByLabelText('Filter breadcrumb items'), {
        target: { value: search },
      })
    );
    await act(async () => jest.runAllTimers());
    expect(props.onSearchChange).toHaveBeenLastCalledWith(search);
  });
});
