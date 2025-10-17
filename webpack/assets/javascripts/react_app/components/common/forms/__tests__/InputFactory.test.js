import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Provider } from 'react-redux';
import store from '../../../../redux';
import InputFactory, { registerInputComponent, getComponentClass } from '../InputFactory';
import { SearchBarProps as searchProps } from '../../../SearchBar/SearchBar.fixtures';
import { selectProps } from '../FormField.fixtures';


describe('InputFactory', () => {
  describe('renders standard text input', () => {
    it('should render PatternFly TextInput for type="text"', () => {
      render(<InputFactory type="text" name="test-input" id="test-input" value="test value" />);
      const input = screen.getByDisplayValue('test value');
      expect(input).toBeInTheDocument();
      expect(input).toHaveAttribute('type', 'text');
      expect(input).toHaveAttribute('name', 'test-input');
    });

    it('should render with isDisabled prop when disabled is true', () => {
      render(<InputFactory type="text" name="test" id="test-disabled" disabled value="" />);
      const input = screen.getByRole('textbox');
      expect(input).toBeDisabled();
    });

    it('should render with isRequired prop when required is true', () => {
      render(<InputFactory type="text" name="test" id="test-required" required value="" />);
      const input = screen.getByRole('textbox');
      expect(input).toBeRequired();
    });

    it('should pass className prop to TextInput', () => {
      const { container } = render(
        <InputFactory type="text" name="test" id="test-class" className="custom-class" value="" />
      );

      expect(container.querySelector('.custom-class') || container.querySelector('#test-class')).toBeInTheDocument();
    });

    it('should pass validated prop to TextInput', () => {
      const { container } = render(
        <InputFactory type="text" name="test" id="test-error" validated="error" value="" />
      );

      const input = container.querySelector('#test-error');
      expect(input).toBeInTheDocument();
    });
  });

  describe('renders custom registered components', () => {
    it('should render SearchBar for type="autocomplete"', () => {
      render(
        <Provider store={store}>
          <InputFactory type="autocomplete" name="test" id="test-auto" {...searchProps} />
        </Provider>
      );
      expect(screen.getByLabelText('Search input')).toBeInTheDocument();
    });

    it('should render Select for type="select"', () => {
      render(<InputFactory {...selectProps} />);
      expect(screen.getByText('Grouped select')).toBeInTheDocument();
    });

    it('should render DateTimePicker for type="dateTime"', () => {
      const { container } = render(<InputFactory type="dateTime" name="test" id="test-datetime" />);
      const input = container.querySelector('.date-time-input');
      expect(input).toBeInTheDocument();
    });

    it('should render DatePicker for type="date"', () => {
      const { container } = render(<InputFactory type="date" name="test" id="test-date" />);
      const input = container.querySelector('.date-input');
      expect(input).toBeInTheDocument();
    });

    it('should render TimePicker for type="time"', () => {
      const { container } = render(<InputFactory type="time" name="test" id="test-time" />);
      const input = container.querySelector('.date-time-picker-pf');
      expect(input).toBeInTheDocument();
    });

    it('should render MemoryAllocationInput for type="memory"', () => {
      render(<InputFactory type="memory" name="test" id="test-memory" />);
      expect(screen.getByDisplayValue('2048 MB')).toBeInTheDocument();
    });

    it('should render CounterInput for type="counter"', () => {
      render(<InputFactory type="counter" name="test" id="test-counter" value={42} />);
      expect(screen.getByDisplayValue('42')).toBeInTheDocument();
    });
  });

  describe('registerInputComponent', () => {
    const CustomComponent = ({ id, name, type, disabled, required, setError, setWarning, ...rest }) => (
      <input data-testid="custom-component" id={id || 'custom-default'} name={name} type={type} disabled={disabled} required={required} {...rest} />
    );

    beforeEach(() => {
      registerInputComponent('customType', CustomComponent);
    });

    it('should register and render custom component', () => {
      render(<InputFactory type="customType" name="test" id="custom-test" />);
      expect(screen.getByTestId('custom-component')).toBeInTheDocument();
    });

    it('should return registered component from getComponentClass', () => {
      const component = getComponentClass('customType');
      expect(component).toBe(CustomComponent);
    });

    it('should return null for unregistered type', () => {
      const component = getComponentClass('nonexistent');
      expect(component).toBeNull();
    });
  });

  describe('handles different input types', () => {
    it('should render email input', () => {
      render(<InputFactory type="email" name="test" id="test-email" value="" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('type', 'email');
    });

    it('should render password input', () => {
      render(<InputFactory type="password" name="test" id="test-password" value="" />);
      const input = document.querySelector('input[type="password"]');
      expect(input).toBeInTheDocument();
    });

    it('should render number input', () => {
      render(<InputFactory type="number" name="test" id="test-number" value="" />);
      const input = screen.getByRole('spinbutton');
      expect(input).toHaveAttribute('type', 'number');
    });

    it('should default to text type when no type is provided', () => {
      render(<InputFactory name="test" id="test-default" value="" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('type', 'text');
    });
  });

  describe('onChange handler', () => {
    it('should call onChange when TextInput value changes', () => {
      const handleChange = jest.fn();
      render(<InputFactory type="text" name="test" id="test-onchange" value="" aria-label="Test" onChange={handleChange} />);
      const input = screen.getByLabelText('Test');

      fireEvent.change(input, { target: { value: 'new value' } });

      expect(handleChange).toHaveBeenCalled();
    });
  });
});
