import React from 'react';
import { Provider } from 'react-redux';
import store from '../../../../redux';
import {
  fireEvent,
  screen,
  render,
  act,
  waitFor,
} from '@testing-library/react';
import '@testing-library/jest-dom';
import { flushPatternflyTimers } from '../../../../common/rtlTestHelpers';
import Bookmarks from '../Bookmarks';
import { STATUS } from '../../../../constants';
import history from '../../../../history';

const helpersNewWindow = jest.fn();
window.open = args => {
  helpersNewWindow(args);
  return {};
};
const historyPush = jest.spyOn(history, 'push');

const commonFixture = {
  id: 'architectures',
  controller: 'architectures',
  onBookmarkClick: () => {},
  url: '/api/v2/architectures',
  documentationUrl: 'https://test-docs.com',
  canCreate: true,
  status: STATUS.PENDING,
  errors: null,
  bookmarks: [],
  searchQuery: 'query',
};

describe('Bookmarks', () => {
  it('loading has all base items', async () => {
    render(
      <Provider store={store}>
        <Bookmarks {...commonFixture} />
      </Provider>
    );
    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await flushPatternflyTimers();
    expect(screen.queryAllByText('Bookmark this search')).toHaveLength(1);
    expect(screen.queryAllByLabelText('loading bookmarks')).toHaveLength(1);
    fireEvent.click(screen.getByText('Manage Bookmarks'));
    expect(historyPush).toHaveBeenCalledWith({
      pathname: '/bookmarks',
      search: '?page=1&per_page=25&search=controller%3Darchitectures',
    });
    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await flushPatternflyTimers();
    fireEvent.click(screen.getByText('Documentation'));
    expect(helpersNewWindow).toHaveBeenCalledWith('https://test-docs.com');
  });
  it('success load with no bookmarks has all base items', async () => {
    render(
      <Provider store={store}>
        <Bookmarks {...commonFixture} status={STATUS.RESOLVED} />
      </Provider>
    );
    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await flushPatternflyTimers();
    expect(screen.queryAllByText('Bookmark this search')).toHaveLength(1);
    expect(screen.queryAllByLabelText('loading bookmarks')).toHaveLength(0);
    expect(screen.queryAllByText('None found')).toHaveLength(1);
    fireEvent.click(screen.getByText('Manage Bookmarks'));
    expect(historyPush).toHaveBeenCalledWith({
      pathname: '/bookmarks',
      search: '?page=1&per_page=25&search=controller%3Darchitectures',
    });
    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await flushPatternflyTimers();
    fireEvent.click(screen.getByText('Documentation'));
    expect(helpersNewWindow).toHaveBeenCalledWith('https://test-docs.com');
  });

  it('bookmark click', async () => {
    const onBookmarkClick = jest.fn();
    render(
      <Provider store={store}>
        <Bookmarks
          {...commonFixture}
          status={STATUS.RESOLVED}
          bookmarks={[
            {
              name: 'my-bookmark',
              controller: 'architectures',
              query: 'name ~ 86',
            },
          ]}
          onBookmarkClick={onBookmarkClick}
        />
      </Provider>
    );

    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await flushPatternflyTimers();
    expect(screen.queryAllByText('Bookmark this search')).toHaveLength(1);
    expect(screen.queryAllByLabelText('loading bookmarks')).toHaveLength(0);
    fireEvent.click(screen.getByText('my-bookmark'));
    expect(onBookmarkClick).toHaveBeenCalledWith('name ~ 86');
    expect(screen.getByLabelText('bookmarks dropdown toggle')).toHaveAttribute(
      'aria-expanded',
      'false'
    );
    await waitFor(() =>
      expect(screen.queryAllByText('my-bookmark')).toHaveLength(0)
    );
  });

  it('shows the saved bookmarks group label and toggle expanded state', async () => {
    render(
      <Provider store={store}>
        <Bookmarks {...commonFixture} status={STATUS.RESOLVED} />
      </Provider>
    );
    const toggle = screen.getByLabelText('bookmarks dropdown toggle');
    expect(toggle).toHaveAttribute('aria-expanded', 'false');
    await act(async () => {
      fireEvent.click(toggle);
    });
    await flushPatternflyTimers();
    expect(toggle).toHaveAttribute('aria-expanded', 'true');
    expect(screen.queryAllByText('Saved Bookmarks')).toHaveLength(1);
  });

  it('hides create and manage items when the user cannot create', async () => {
    render(
      <Provider store={store}>
        <Bookmarks
          {...commonFixture}
          status={STATUS.RESOLVED}
          canCreate={false}
        />
      </Provider>
    );
    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await flushPatternflyTimers();
    expect(screen.queryAllByText('Bookmark this search')).toHaveLength(0);
    expect(screen.queryAllByText('Manage Bookmarks')).toHaveLength(0);
    expect(screen.queryAllByText('None found')).toHaveLength(1);
  });

  it('show error', async () => {
    const onBookmarkClick = jest.fn();
    render(
      <Provider store={store}>
        <Bookmarks
          {...commonFixture}
          status={STATUS.ERROR}
          errors="Random test error"
        />
      </Provider>
    );

    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await flushPatternflyTimers();
    expect(screen.queryAllByText('Bookmark this search')).toHaveLength(1);
    fireEvent.click(screen.getByText('Manage Bookmarks'));
    expect(historyPush).toHaveBeenCalledWith({
      pathname: '/bookmarks',
      search: '?page=1&per_page=25&search=controller%3Darchitectures',
    });
    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await flushPatternflyTimers();
    fireEvent.click(screen.getByText('Documentation'));
    expect(helpersNewWindow).toHaveBeenCalledWith('https://test-docs.com');
    expect(screen.queryAllByLabelText('loading bookmarks')).toHaveLength(0);
    await act(async () => {
      fireEvent.click(screen.getByLabelText('bookmarks dropdown toggle'));
    });
    await flushPatternflyTimers();
    expect(
      screen.queryAllByText('Failed to load bookmarks: Random test error')
    ).toHaveLength(1);
  });
});
