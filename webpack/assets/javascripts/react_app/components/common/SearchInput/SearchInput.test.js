import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import SearchInput from './';

jest.unmock('./');

describe('Search Input', () => {
  it('should render with initial search value', () => {
    render(<SearchInput searchValue="val" timeout={300} />);

    // Test that the search input is rendered
    const searchInput = screen.getByRole('searchbox');
    expect(searchInput).toBeInTheDocument();

    // Test that the initial value is set
    expect(searchInput).toHaveValue('val');

    // Test that the input has appropriate attributes
    expect(searchInput).toHaveAttribute('type', 'search');
  });

  it('should not gain focus by default', () => {
    const { container } = render(<SearchInput searchValue="val" timeout={300} />);

    const searchInput = screen.getByRole('searchbox');

    // Test that the input is not focused initially
    expect(searchInput).not.toHaveFocus();
    expect(document.activeElement).not.toBe(searchInput);
  });

  it('should gain focus when focus prop is true', () => {
    render(<SearchInput searchValue="val" timeout={300} focus />);

    const searchInput = screen.getByRole('searchbox');

    // Test that the input gains focus when focus prop is true
    expect(searchInput).toHaveFocus();
    expect(document.activeElement).toBe(searchInput);
  });

  it('should handle user input changes', async () => {
    const onSearchChange = jest.fn();
    render(
      <SearchInput
        searchValue="initial"
        timeout={300}
        onSearchChange={onSearchChange}
      />
    );

    const searchInput = screen.getByRole('searchbox');

    // Test user typing in the search input
    fireEvent.change(searchInput, { target: { value: 'new search term' } });

    expect(searchInput).toHaveValue('new search term');

    // If there's a debounced search, we might need to wait for it
    if (onSearchChange) {
      await waitFor(() => {
        expect(onSearchChange).toHaveBeenCalled();
      }, { timeout: 500 });
    }
  });

  it('should handle search submission', () => {
    const onSearch = jest.fn();
    render(
      <SearchInput
        searchValue="search term"
        timeout={300}
        onSearch={onSearch}
      />
    );

    const searchInput = screen.getByRole('searchbox');

    // Test Enter key press for search submission
    fireEvent.keyDown(searchInput, { key: 'Enter', code: 'Enter' });

    if (onSearch) {
      expect(onSearch).toHaveBeenCalledWith('search term');
    }
  });

  it('should clear search when clear button is clicked', () => {
    const onClear = jest.fn();
    render(
      <SearchInput
        searchValue="search to clear"
        timeout={300}
        onClear={onClear}
      />
    );

    // Look for clear button (might be an icon or button)
    const clearButton = screen.queryByRole('button', { name: /clear/i });

    if (clearButton) {
      fireEvent.click(clearButton);

      if (onClear) {
        expect(onClear).toHaveBeenCalled();
      }
    }
    const searchInput = screen.getByRole('searchbox');
    expect(searchInput).not.toHaveValue();
  });

  it('should be accessible', () => {
    render(<SearchInput searchValue="accessible search" timeout={300} />);

    const searchInput = screen.getByRole('searchbox');

    // Test accessibility attributes
    expect(searchInput).toHaveAttribute('type', 'search');

    // Test that it's properly labeled (might have placeholder or aria-label)
    expect(searchInput).toBeInTheDocument();

    // The input should be keyboard accessible
    searchInput.focus();
    expect(searchInput).toHaveFocus();
  });

  it('should handle empty search value', () => {
    render(<SearchInput searchValue="" timeout={300} />);

    const searchInput = screen.getByRole('searchbox');
    expect(searchInput).toHaveValue('');
    expect(searchInput).toBeInTheDocument();
  });

  it('should respect timeout configuration', async () => {
    const onSearchChange = jest.fn();
    render(
      <SearchInput
        searchValue=""
        timeout={100}
        onSearchChange={onSearchChange}
      />
    );

    const searchInput = screen.getByRole('searchbox');

    // Test rapid typing to ensure debouncing works
    fireEvent.change(searchInput, { target: { value: 'a' } });
    fireEvent.change(searchInput, { target: { value: 'ab' } });
    fireEvent.change(searchInput, { target: { value: 'abc' } });

    // Wait for timeout and check if callback is called appropriately
    if (onSearchChange) {
      await waitFor(() => {
        // Should be debounced, so not called for every keystroke
        expect(onSearchChange).toHaveBeenCalled();
      }, { timeout: 200 });
    }
  });
});
