import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import FieldConstructor from '../FieldConstructor';

const defaultProps = {
  name: 'test-field',
  setValue: jest.fn(),
  label: 'Test Field',
  value: '',
  type: 'text',
};

describe('FieldConstructor RTL Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Text Input Fields', () => {
    test('renders text input field', () => {
      render(<FieldConstructor {...defaultProps} type="text" />);

      expect(screen.getByText('Test Field')).toBeInTheDocument();
      expect(document.getElementById('id-test-field')).toHaveAttribute(
        'type',
        'text'
      );
    });

    test('renders password input field', () => {
      render(<FieldConstructor {...defaultProps} type="password" />);

      expect(screen.getByText('Test Field')).toBeInTheDocument();
      expect(document.getElementById('id-test-field')).toHaveAttribute(
        'type',
        'password'
      );
    });

    test('calls setValue when text input changes', () => {
      render(<FieldConstructor {...defaultProps} type="text" />);

      const input = document.getElementById('id-test-field');
      fireEvent.change(input, { target: { value: 'test value' } });

      expect(defaultProps.setValue).toHaveBeenCalledWith(
        'test-field',
        'test value'
      );
    });

    test('renders with initial value', () => {
      render(
        <FieldConstructor {...defaultProps} type="text" value="initial value" />
      );

      expect(document.getElementById('id-test-field')).toHaveValue(
        'initial value'
      );
    });

    test('renders as enabled when loading', () => {
      render(<FieldConstructor {...defaultProps} type="text" isLoading />);

      expect(document.getElementById('id-test-field')).toBeEnabled();
    });
  });

  describe('Password disabled state', () => {
    test('renders edit button when password is disabled', () => {
      render(
        <FieldConstructor
          {...defaultProps}
          name="password"
          type="password"
          disabled
          setIsPasswordDisabled={jest.fn()}
        />
      );

      expect(
        document.querySelector('[data-ouia-component-id="reset-password"]')
      ).toBeInTheDocument();
      expect(document.getElementById('id-password')).toBeDisabled();
    });

    test('calls setIsPasswordDisabled when edit button is clicked', () => {
      const setIsPasswordDisabled = jest.fn();

      render(
        <FieldConstructor
          {...defaultProps}
          name="password"
          type="password"
          disabled
          setIsPasswordDisabled={setIsPasswordDisabled}
        />
      );

      fireEvent.click(
        document.querySelector('[data-ouia-component-id="reset-password"]')
      );

      expect(setIsPasswordDisabled).toHaveBeenCalledWith(false);
    });

    test('does not render edit button when password is enabled', () => {
      render(
        <FieldConstructor
          {...defaultProps}
          name="password"
          type="password"
          setIsPasswordDisabled={jest.fn()}
        />
      );

      expect(
        document.querySelector('[data-ouia-component-id="reset-password"]')
      ).not.toBeInTheDocument();
    });
  });

  describe('Textarea Fields', () => {
    test('renders textarea field', () => {
      render(<FieldConstructor {...defaultProps} type="textarea" />);

      expect(screen.getByText('Test Field')).toBeInTheDocument();
      expect(document.getElementById('id-test-field').tagName).toBe('TEXTAREA');
    });

    test('calls setValue when textarea changes', () => {
      render(<FieldConstructor {...defaultProps} type="textarea" />);

      const textarea = document.getElementById('id-test-field');
      fireEvent.change(textarea, { target: { value: 'textarea content' } });

      expect(defaultProps.setValue).toHaveBeenCalledWith(
        'test-field',
        'textarea content'
      );
    });

    test('renders with specified rows', () => {
      render(<FieldConstructor {...defaultProps} type="textarea" rows={5} />);

      expect(document.getElementsByTagName('textarea')).toHaveLength(1);
    });
  });

  describe('Checkbox Fields', () => {
    test('renders checkbox field', () => {
      render(<FieldConstructor {...defaultProps} type="checkbox" />);

      expect(screen.getByText('Test Field')).toBeInTheDocument();
      expect(document.getElementById('id-test-field')).toHaveAttribute(
        'type',
        'checkbox'
      );
    });

    test('renders unchecked checkbox', () => {
      render(
        <FieldConstructor {...defaultProps} type="checkbox" value={false} />
      );

      expect(document.getElementById('id-test-field')).not.toBeChecked();
    });
  });

  describe('Autocomplete render test', () => {
    test('renders autocomplete', () => {
      const props = {
        ...defaultProps,
        onChange: defaultProps.setValue,
        options: [
          { value: 'host_created.event.foreman', label: 'Host Created' },
          { value: 'host_updated.event.foreman', label: 'Host Updated' },
        ],
      };
      render(<FieldConstructor {...props} type="select" />);

      expect(screen.getByRole('combobox')).toBeInTheDocument();
    });
  });

  describe('Label Help', () => {
    test('renders help icon when labelHelp is provided', () => {
      render(
        <FieldConstructor {...defaultProps} labelHelp="This is help text" />
      );

      expect(screen.getByRole('button')).toBeInTheDocument();
    });

    test('does not render help icon when labelHelp is not provided', () => {
      render(<FieldConstructor {...defaultProps} />);

      expect(screen.queryByRole('button')).not.toBeInTheDocument();
    });

    test('renders help icon with JSX content', async () => {
      const helpContent = <div>JSX help content</div>;
      render(<FieldConstructor {...defaultProps} labelHelp={helpContent} />);

      const button = screen.getByRole('button');
      expect(button).toBeInTheDocument();

      userEvent.click(button);

      expect(await screen.findByText('JSX help content')).toBeInTheDocument();
    });
  });

  describe('Validation', () => {
    test('renders error message when validated is error', async () => {
      render(
        <>
          <FieldConstructor {...defaultProps} required type="text" />
          <button>Dummy</button>
        </>
      );

      const input = document.getElementById('id-test-field');
      await userEvent.click(input);
      expect(input).toHaveFocus();

      await userEvent.tab();
      expect(input).not.toHaveFocus();

      expect(screen.getByText('Field is required')).toBeInTheDocument();
    });

    test('does not render error message when validated is not error', () => {
      render(
        <FieldConstructor {...defaultProps} type="text" validated="success" />
      );

      expect(screen.queryByText('Field is required')).not.toBeInTheDocument();
    });
  });

  describe('Edge Cases', () => {
    test('handles undefined value', () => {
      render(
        <FieldConstructor {...defaultProps} type="text" value={undefined} />
      );

      expect(document.getElementById('id-test-field')).toHaveValue('');
    });

    test('handles null value', () => {
      render(<FieldConstructor {...defaultProps} type="text" value={null} />);

      expect(document.getElementById('id-test-field')).toHaveValue('');
    });

    test('handles numeric value', () => {
      render(<FieldConstructor {...defaultProps} type="text" value={123} />);

      expect(document.getElementById('id-test-field')).toHaveValue('123');
    });

    test('handles boolean value for checkbox', () => {
      render(<FieldConstructor {...defaultProps} type="checkbox" value />);

      expect(document.getElementById('id-test-field')).toBeChecked();
    });
  });
});
