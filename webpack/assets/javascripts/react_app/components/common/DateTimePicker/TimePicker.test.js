import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import TimePicker from './TimePicker';

describe('TimePicker', () => {
  test('renders properly', () => {
    render(<TimePicker />);
    
    const timeInput = screen.getByLabelText('Time picker');
    expect(timeInput).toBeInTheDocument();
  });

  test('prefils the value from prop', () => {
    const testTime = '14:30';
    const { container } = render(<TimePicker value={testTime} />);
    
    const timeInput = container.querySelector('input');
    expect(timeInput).toBeInTheDocument();
    expect(timeInput).toHaveValue(testTime);
  });

  test('edit works', () => {
    const testTime = '14:30';
    const { container } = render(<TimePicker value={testTime} />);
    const timeInput = container.querySelector('input');
    expect(timeInput).toHaveValue(testTime);
    fireEvent.change(timeInput, { target: { value: '16:45' } });
    expect(timeInput).toHaveValue('16:45');
  });

  test('calls onChange callback when provided', () => {
    const onChange = jest.fn();
    const initialTime = '14:30';
    const { container } = render(<TimePicker onChange={onChange} value={initialTime} />);
    
    const timeInput = container.querySelector('input');
    fireEvent.change(timeInput, { target: { value: '18:00' } });
    
    expect(onChange).toHaveBeenCalledWith('18:00');
  });

  test('passes props to PatternFly TimePicker', () => {
    const { container } = render(
      <TimePicker
        name="test-time"
        id="test-time-picker"
        locale="en-US"
      />
    );
    
    const timeInput = container.querySelector('input[name="test-time"]');
    
    expect(timeInput).toBeInTheDocument();
    expect(timeInput).toHaveAttribute('name', 'test-time');
    expect(timeInput).toHaveAttribute('id', 'test-time-picker');
  });
});
