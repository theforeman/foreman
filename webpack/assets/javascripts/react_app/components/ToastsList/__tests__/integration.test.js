import React from 'react';
import { screen, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import ToastsList, { addToast, deleteToast } from '../index';
import { toast } from './fixtures';
import { rtlHelpers } from '../../../common/rtlTestHelpers';

const { renderWithStore } = rtlHelpers;

const longMessage =
  'This is long message. Long, long, long, long, long, long, long, long, long, long, long. Too long.';

describe('ToastsList', () => {
  it('renders no toasts initially', () => {
    renderWithStore(<ToastsList />);

    expect(
      screen.queryByRole('button', { name: /^Close / })
    ).not.toBeInTheDocument();
  });

  it('shows a toast after addToast is dispatched', () => {
    const { store } = renderWithStore(<ToastsList />);

    store.dispatch(addToast(toast));

    expect(screen.getByText('message')).toBeInTheDocument();
  });

  it('removes a toast after deleteToast is dispatched', () => {
    const { store } = renderWithStore(<ToastsList />);

    store.dispatch(addToast(toast));
    expect(screen.getByText('message')).toBeInTheDocument();

    store.dispatch(deleteToast(toast.key));
    expect(screen.queryByText('message')).not.toBeInTheDocument();
  });

  it('shows toasts from railsMessages on mount', () => {
    renderWithStore(
      <ToastsList
        railsMessages={[{ message: 'Rails message', type: 'info' }]}
      />
    );

    expect(screen.getByText('Rails message')).toBeInTheDocument();
  });

  it('removes a toast when the close button is clicked', () => {
    const { store } = renderWithStore(<ToastsList />);

    store.dispatch(addToast(toast));
    expect(screen.getByText('message')).toBeInTheDocument();

    userEvent.click(
      screen.getByRole('button', { name: 'Close Success alert: alert: message' })
    );

    expect(screen.queryByText('message')).not.toBeInTheDocument();
  });

  it('shows a link when the toast has link data', () => {
    const { store } = renderWithStore(<ToastsList />);

    store.dispatch(
      addToast({
        message: 'with link',
        type: 'info',
        key: 'link-toast',
        link: { href: '/hosts', children: 'View hosts' },
      })
    );

    const link = screen.getByRole('link', { name: 'View hosts' });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '/hosts');
  });

  it('shows long messages in the body with a shortened title', () => {
    const { store } = renderWithStore(<ToastsList />);

    store.dispatch(
      addToast({ message: longMessage, type: 'error', key: 'long-toast' })
    );

    expect(screen.getByText('Error')).toBeInTheDocument();
    expect(screen.getByText(longMessage)).toBeInTheDocument();
  });

  describe('toast timeout', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it('removes a non-sticky toast after the timeout', () => {
      const { store } = renderWithStore(<ToastsList />);

      store.dispatch(
        addToast({ message: 'timed toast', type: 'success', key: 'timed' })
      );
      expect(screen.getByText('timed toast')).toBeInTheDocument();

      act(() => {
        jest.advanceTimersByTime(8000);
      });

      expect(screen.queryByText('timed toast')).not.toBeInTheDocument();
    });

    it('keeps a sticky toast after the timeout', () => {
      const { store } = renderWithStore(<ToastsList />);

      store.dispatch(
        addToast({
          message: 'sticky toast',
          type: 'error',
          key: 'sticky',
          sticky: true,
        })
      );
      expect(screen.getByText('sticky toast')).toBeInTheDocument();

      act(() => {
        jest.advanceTimersByTime(8000);
      });

      expect(screen.getByText('sticky toast')).toBeInTheDocument();
    });
  });
});
