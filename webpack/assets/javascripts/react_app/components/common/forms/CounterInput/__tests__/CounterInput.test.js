import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import CounterInput from '../';
import FormField from '../../FormField';

describe('CounterInput', () => {
  const defaultProps = {
    id: 'test-counter',
    name: 'test-counter',
    value: 1,
    onChange: jest.fn(),
    setError: jest.fn(),
    setWarning: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('rendering', () => {
    it('should render with default props', () => {
      render(<CounterInput {...defaultProps} />);
      const input = screen.getByRole('spinbutton');
      expect(input).toBeInTheDocument();
      expect(input).toHaveValue(1);
      expect(input).not.toBeDisabled();
    });

    it('should render with id and name attributes', () => {
      render(
        <CounterInput {...defaultProps} id="custom-id" name="custom-name" />
      );
      const input = screen.getByRole('spinbutton');
      expect(input).toHaveAttribute('id', 'custom-id');
      expect(input).toHaveAttribute('name', 'custom-name');
    });

    it('should render disabled state', () => {
      render(<CounterInput {...defaultProps} disabled />);
      const input = screen.getByRole('spinbutton');
      expect(input).toBeDisabled();
    });
  });
  describe('validation', () => {
    const renderFormField = (props = {}) =>
      render(
        <FormField
          type="counter"
          id="test-counter"
          name="test-counter"
          label="CPU Count"
          {...props}
        />
      );

    it('should display warning message when value exceeds recommendedMaxValue', () => {
      renderFormField({ value: 11, recommendedMaxValue: 10 });

      expect(
        screen.getByText(/Specified value is higher than recommended maximum 10/)
      ).toBeInTheDocument();
    });

    it('should display error message when value exceeds max', () => {
      renderFormField({ value: 21, max: 20 });

      expect(
        screen.getByText(/Specified value is higher than maximum value 20/)
      ).toBeInTheDocument();
      expect(screen.getByRole('spinbutton')).toBeInvalid();
    });

    it('should prioritize error over warning when both conditions are met', () => {
      renderFormField({ value: 25, max: 20, recommendedMaxValue: 15 });

      expect(
        screen.getByText(/Specified value is higher than maximum value 20/)
      ).toBeInTheDocument();
      expect(
        screen.queryByText(/Specified value is higher than recommended maximum/)
      ).not.toBeInTheDocument();
    });

    it('should clear warning when value becomes valid', () => {
      renderFormField({ value: 11, recommendedMaxValue: 10 });

      expect(
        screen.getByText(/Specified value is higher than recommended maximum 10/)
      ).toBeInTheDocument();

      fireEvent.change(screen.getByRole('spinbutton'), {
        target: { value: '8' },
      });

      expect(
        screen.queryByText(/Specified value is higher than recommended maximum/)
      ).not.toBeInTheDocument();
    });

    it('should clear error when value becomes valid', () => {
      renderFormField({ value: 21, max: 20 });

      expect(screen.getByRole('spinbutton')).toBeInvalid();

      fireEvent.change(screen.getByRole('spinbutton'), {
        target: { value: '15' },
      });

      expect(screen.getByRole('spinbutton')).toBeValid();
      expect(
        screen.queryByText(/Specified value is higher than maximum value/)
      ).not.toBeInTheDocument();
    });

    it('should not display error or warning when value is within limits', () => {
      renderFormField({ value: 5, max: 20, recommendedMaxValue: 10 });

      expect(screen.getByRole('spinbutton')).toBeValid();
      expect(
        screen.queryByText(/Specified value is higher than maximum value/)
      ).not.toBeInTheDocument();
      expect(
        screen.queryByText(/Specified value is higher than recommended maximum/)
      ).not.toBeInTheDocument();
    });
  });

  describe('user interactions', () => {
    it('should call onChange when input value changes', () => {
      const onChange = jest.fn();
      render(<CounterInput {...defaultProps} onChange={onChange} />);
      const input = screen.getByRole('spinbutton');

      fireEvent.change(input, { target: { value: '5' } });

      expect(onChange).toHaveBeenCalledWith(5);
    });

    it('should handle empty input by setting to min value', () => {
      const onChange = jest.fn();
      render(<CounterInput {...defaultProps} onChange={onChange} min={1} />);
      const input = screen.getByRole('spinbutton');

      fireEvent.change(input, { target: { value: '' } });

      expect(onChange).toHaveBeenCalledWith('');
      fireEvent.blur(input);
      expect(onChange).toHaveBeenCalledWith(1);
    });

    it('should increment value when plus button is clicked', () => {
      const onChange = jest.fn();
      render(<CounterInput {...defaultProps} value={5} onChange={onChange} />);
      const plusButton = screen.getByLabelText('Plus');

      fireEvent.click(plusButton);

      expect(onChange).toHaveBeenCalledWith(6);
    });

    it('should decrement value when minus button is clicked', () => {
      const onChange = jest.fn();
      render(<CounterInput {...defaultProps} value={5} onChange={onChange} />);
      const minusButton = screen.getByLabelText('Minus');

      fireEvent.click(minusButton);

      expect(onChange).toHaveBeenCalledWith(4);
    });

    it('should use custom step when incrementing', () => {
      const onChange = jest.fn();
      render(
        <CounterInput
          {...defaultProps}
          value={5}
          step={3}
          onChange={onChange}
        />
      );
      const plusButton = screen.getByLabelText('Plus');

      fireEvent.click(plusButton);

      expect(onChange).toHaveBeenCalledWith(8);
    });

    it('should use custom step when decrementing', () => {
      const onChange = jest.fn();
      render(
        <CounterInput
          {...defaultProps}
          value={10}
          step={3}
          onChange={onChange}
        />
      );
      const minusButton = screen.getByLabelText('Minus');

      fireEvent.click(minusButton);

      expect(onChange).toHaveBeenCalledWith(7);
    });

    it('should handle null value in increment', () => {
      const onChange = jest.fn();
      render(
        <CounterInput {...defaultProps} value={null} onChange={onChange} />
      );
      const plusButton = screen.getByLabelText('Plus');

      fireEvent.click(plusButton);

      expect(onChange).toHaveBeenCalledWith(1);
    });

    it('should handle null value in decrement', () => {
      const onChange = jest.fn();
      render(
        <CounterInput
          {...defaultProps}
          min={-10}
          value={null}
          onChange={onChange}
        />
      );
      const minusButton = screen.getByLabelText('Minus');
      const input = screen.getByRole('spinbutton');
      expect(input).toHaveValue(0);
      expect(minusButton).not.toBeDisabled();
      fireEvent.click(minusButton);
      expect(input).toHaveValue(-1);
      expect(onChange).toHaveBeenCalledWith(-1);
    });
  });

  describe('step', () => {
    it('should handle decimal step values', () => {
      const onChange = jest.fn();
      render(
        <CounterInput
          {...defaultProps}
          value={5}
          step={0.5}
          onChange={onChange}
        />
      );
      const plusButton = screen.getByLabelText('Plus');
      const input = screen.getByRole('spinbutton');
      expect(input).toHaveValue(5);
      fireEvent.click(plusButton);
      expect(input).toHaveValue(5.5);

      expect(onChange).toHaveBeenCalledWith(5.5);
    });
  });
});
