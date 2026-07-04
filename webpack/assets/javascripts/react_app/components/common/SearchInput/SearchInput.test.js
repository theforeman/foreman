import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import SearchInput from './';

// Force the real component: opt out of any (auto)mock of this module so the
// tests exercise the actual SearchInput rather than a stubbed version.
jest.unmock('./');

describe('Search Input', () => {
  it('renders the search input with its value and a clear button', () => {
    render(<SearchInput searchValue="val" timeout={300} />);

    const input = screen.getByPlaceholderText('filter...');
    expect(input).toHaveValue('val');
    expect(
      screen.getByRole('button', { name: 'Clear' })
    ).toBeInTheDocument();
  });

  it('calls onClear when the clear button is clicked', async () => {
    const onClear = jest.fn();
    render(
      <SearchInput searchValue="val" timeout={300} onClear={onClear} />
    );

    await userEvent.click(screen.getByRole('button', { name: 'Clear' }));

    expect(onClear).toHaveBeenCalledTimes(1);
  });

  it('calls onSearchChange with the typed value', async () => {
    const onSearchChange = jest.fn();
    // timeout=0 so the debounced onChange fires without a real wait
    render(
      <SearchInput
        searchValue=""
        timeout={0}
        onSearchChange={onSearchChange}
      />
    );

    await userEvent.type(screen.getByPlaceholderText('filter...'), 'abc');

    await waitFor(() => expect(onSearchChange).toHaveBeenCalled());
    // onSearchChange receives the change event; its target holds the new value
    const lastCall = onSearchChange.mock.calls[onSearchChange.mock.calls.length - 1];
    expect(lastCall[0].target.value).toBe('abc');
  });

  it('does not focus the input by default', () => {
    render(<SearchInput searchValue="val" timeout={300} />);

    expect(screen.getByPlaceholderText('filter...')).not.toHaveFocus();
  });

  it('focuses the input when focus is set', () => {
    render(<SearchInput searchValue="val" timeout={300} focus />);

    expect(screen.getByPlaceholderText('filter...')).toHaveFocus();
  });
});
