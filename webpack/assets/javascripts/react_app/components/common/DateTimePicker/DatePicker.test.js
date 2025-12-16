import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import DatePicker from './DatePicker';

describe('DatePicker', () => {
  test('renders properly', async () => {
    const { container } = render(<DatePicker />);
    
    const wrapper = container.querySelector('.date-picker-pf-wrapper');
    expect(wrapper).toBeInTheDocument();
    const calendarButton = screen.getByLabelText('Toggle date picker');
    expect(calendarButton).toBeInTheDocument();
    
    await act(async () => {
      fireEvent.click(calendarButton);
    });
    const todayButton = screen.getByText('Today');
    expect(todayButton).toBeInTheDocument();
    const clearButton = screen.getByText('Clear');
    expect(clearButton).toBeInTheDocument();
  });

  test('prefils the value from prop', () => {
    const testDate = new Date('2024-01-15');
    const { container } = render(<DatePicker value={testDate} />);
    const dateInput = container.querySelector('input');
    
    expect(dateInput).toBeInTheDocument();
    expect(dateInput).toHaveValue('2024-01-15');
  });

  test('edit works', () => {
    const { container } = render(<DatePicker />);
    
    const dateInput = container.querySelector('input');
  
    fireEvent.change(dateInput, { target: { value: '2024-12-25' } });

    expect(dateInput).toHaveValue('2024-12-25');
  });

  test('clear button clears the value', async () => {
    const testDate = new Date('2024-01-15');
    const { container } = render(<DatePicker value={testDate} />);
    
    const dateInput = container.querySelector('input');
    expect(dateInput).toHaveValue('2024-01-15');

    const calendarButton = screen.getByLabelText('Toggle date picker');
    await act(async () => {
      fireEvent.click(calendarButton);
    });
    const clearButton = await screen.findByText('Clear');
    fireEvent.click(clearButton);
    expect(dateInput).toHaveValue('');
  });

  test('passes props to PatternFly DatePicker', () => {
    const { container } = render(
      <DatePicker
        name="test-date"
        id="test-date-picker"
        locale="en-US"
        weekStartsOn={0}
        placement="bottom"
        required
      />
    );
  
    const dateInput = container.querySelector('input[name="test-date"]');
    expect(dateInput).toBeInTheDocument();
    expect(dateInput).toHaveAttribute('name', 'test-date');
    expect(dateInput).toHaveAttribute('id', 'test-date-picker');
  });

  test('shows error when required field is empty and blurred', () => {
    const { container } = render(<DatePicker required />);
    
    const dateInput = container.querySelector('input');
    
    expect(screen.queryByText('Date is required')).not.toBeInTheDocument();
    fireEvent.change(dateInput, { target: { value: '' } });
    fireEvent.blur(dateInput);
    expect(screen.queryByText('Date is required')).toBeInTheDocument();
    
    expect(dateInput).toHaveAttribute('aria-invalid', 'true');
  });
});
