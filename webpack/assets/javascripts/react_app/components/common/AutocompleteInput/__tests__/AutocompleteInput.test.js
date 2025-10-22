import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import AutocompleteInput from '../AutocompleteInput';

const setSelected = jest.fn();
const defaultProps = {
  selected: '',
  onSelect: setSelected,
  name: 'test-field',
  options: [
    { value: 'option1', label: 'Option 1' },
    { value: 'option2', label: 'Option 2' },
    { value: 'option3', label: 'Option 3' },
  ],
};

describe('AutocompleteInput RTL Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Rendering', () => {
    test('renders input field with placeholder', () => {
      render(<AutocompleteInput {...defaultProps} />);

      expect(
        screen.getByPlaceholderText('Start typing to search')
      ).toBeInTheDocument();
    });

    test('renders with initial selected value', () => {
      render(<AutocompleteInput {...defaultProps} selected="option1" />);

      const input = screen.getByRole('combobox');
      expect(input).toHaveValue('Option 1');
    });
  });

  describe('Filtering', () => {
    test('filters options based on input', async () => {
      render(<AutocompleteInput {...defaultProps} />);

      const input = screen.getByRole('combobox');
      fireEvent.change(input, { target: { value: 'Option 1' } });

      await waitFor(() => {
        expect(screen.getByText('Option 1')).toBeInTheDocument();
        expect(screen.queryByText('Option 2')).not.toBeInTheDocument();
        expect(screen.queryByText('Option 3')).not.toBeInTheDocument();
      });
    });

    test('shows no results message when no matches', async () => {
      render(<AutocompleteInput {...defaultProps} />);

      const input = screen.getByRole('combobox');
      fireEvent.change(input, { target: { value: 'nonexistent' } });

      await waitFor(() => {
        expect(
          screen.getByText('No results found for nonexistent')
        ).toBeInTheDocument();
      });
    });

    test('case insensitive filtering', async () => {
      render(<AutocompleteInput {...defaultProps} />);

      const input = screen.getByRole('combobox');
      fireEvent.change(input, { target: { value: 'option 1' } });

      await waitFor(() => {
        expect(screen.getByText('Option 1')).toBeInTheDocument();
        expect(screen.queryByText('Option 2')).not.toBeInTheDocument();
        expect(screen.queryByText('Option 3')).not.toBeInTheDocument();
      });
    });
  });

  describe('Selection', () => {
    test('selects option when clicked', async () => {
      render(<AutocompleteInput {...defaultProps} />);

      const input = screen.getByRole('combobox');
      fireEvent.click(input);

      await waitFor(() => {
        const option = screen.getByText('Option 1');
        fireEvent.click(option);
      });

      await waitFor(() => {
        expect(setSelected).toHaveBeenCalledWith('option1');
      });
    });

    test('updates input value when option is selected', async () => {
      render(<AutocompleteInput {...defaultProps} />);

      const input = screen.getByRole('combobox');
      fireEvent.click(input);

      await waitFor(() => {
        const option = screen.getByText('Option 2');
        fireEvent.click(option);
      });

      expect(input).toHaveValue('Option 2');
    });

    test('closes dropdown after selection', async () => {
      render(<AutocompleteInput {...defaultProps} />);

      const input = screen.getByRole('combobox');
      fireEvent.click(input);

      await waitFor(() => {
        const option = screen.getByText('Option 1');
        fireEvent.click(option);
      });

      await waitFor(() => {
        expect(screen.queryByRole('listbox')).not.toBeInTheDocument();
      });
    });
  });

  describe('Keyboard Navigation', () => {
    test('opens dropdown on Enter key', async () => {
      render(<AutocompleteInput {...defaultProps} />);

      const input = screen.getByRole('combobox');
      fireEvent.keyDown(input, { key: 'Enter' });

      await waitFor(() => {
        expect(screen.getByRole('listbox')).toBeInTheDocument();
      });
    });

    test('navigates options with arrow keys', async () => {
      render(<AutocompleteInput {...defaultProps} />);

      const input = screen.getByRole('combobox');
      fireEvent.click(input);

      fireEvent.keyDown(input, { key: 'ArrowDown' });
      await waitFor(() => {
        expect(screen.getByText('Option 1')).toHaveClass(
          'pf-v5-c-menu__item-text'
        );
      });
    });
  });

  describe('Edge Cases', () => {
    test('handles empty options array', async () => {
      render(<AutocompleteInput {...defaultProps} options={[]} />);

      const input = screen.getByRole('combobox');
      fireEvent.click(input);

      await waitFor(() => {
        expect(screen.getByText('No matches found')).toBeInTheDocument();
      });
    });

    test('handles undefined selected value', () => {
      render(<AutocompleteInput {...defaultProps} selected={undefined} />);

      const input = screen.getByRole('combobox');
      expect(input).toHaveValue('');
    });

    test('handles numeric selected value', () => {
      render(<AutocompleteInput {...defaultProps} selected={123} />);

      const input = screen.getByRole('combobox');
      expect(input).toHaveValue('123');
    });

    test('handles boolean selected value', () => {
      render(<AutocompleteInput {...defaultProps} selected />);

      const input = screen.getByRole('combobox');
      expect(input).toHaveValue('true');
    });
  });

  describe('Accessibility', () => {
    test('has proper ARIA attributes when focused', async () => {
      render(<AutocompleteInput {...defaultProps} />);

      const input = screen.getByRole('combobox');
      fireEvent.click(input);

      await waitFor(() => {
        fireEvent.keyDown(input, { key: 'ArrowDown' });
        expect(input).toHaveAttribute('aria-activedescendant');
      });
    });
  });
});
