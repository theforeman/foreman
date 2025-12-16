import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import DateTimePicker from './DateTimePicker';

describe('DateTimePicker', () => {
  test('renders properly', async () => {
    const { container } = render(<DateTimePicker />);

    const dateTimeInput = screen.getByLabelText('date and time picker');
    expect(dateTimeInput).toBeInTheDocument();

    const calendarButton = screen.getByLabelText('Toggle date picker');
    expect(calendarButton).toBeInTheDocument();

    const wrapper = container.querySelector('.date-time-picker-pf-wrapper');
    expect(wrapper).toBeInTheDocument();
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
    const testDate = new Date('2024-01-15T14:30:00');
    const { container } = render(<DateTimePicker value={testDate} />);

    const dateTimeInput = container.querySelector(
      'input[aria-label="date and time picker"]'
    );
    expect(dateTimeInput).toBeInTheDocument();
    expect(dateTimeInput).toHaveValue('2024-01-15 14:30');
  });

  test('edit works', () => {
    const { container } = render(<DateTimePicker />);

    const dateTimeInput = container.querySelector(
      'input[aria-label="date and time picker"]'
    );
    fireEvent.change(dateTimeInput, { target: { value: '2024-12-25 16:45' } });

    expect(dateTimeInput).toHaveValue('2024-12-25 16:45');
  });

  test('clear button clears the value', async () => {
    const testDate = new Date('2024-01-15T14:30:00');
    const { container } = render(<DateTimePicker value={testDate} />);

    const dateTimeInput = container.querySelector(
      'input[aria-label="date and time picker"]'
    );
    const calendarButton = screen.getByLabelText('Toggle date picker');

    expect(dateTimeInput).toHaveValue('2024-01-15 14:30');
    await act(async () => {
      fireEvent.click(calendarButton);
    });
    const clearButton = screen.getByText('Clear');
    fireEvent.click(clearButton);
    expect(dateTimeInput).toHaveValue('');
  });

  test('calendar toggle button works', async () => {
    render(<DateTimePicker />);

    const calendarButton = screen.getByLabelText('Toggle date picker');
    expect(calendarButton).toBeInTheDocument();
    expect(screen.queryByRole('dialog')).toBeNull();
    await act(async () => {
      fireEvent.click(calendarButton);
    });
    expect(screen.queryByRole('dialog')).toBeVisible();
  });

  test('shows error when required field is empty', async () => {
    const { container } = render(<DateTimePicker required />);

    const dateTimeInput = container.querySelector(
      'input[aria-label="date and time picker"]'
    );
    const calendarButton = screen.getByLabelText('Toggle date picker');

    expect(
      screen.queryByText('Date and time are required')
    ).not.toBeInTheDocument();
    await act(async () => {
      fireEvent.click(calendarButton);
    });
    const clearButton = screen.getByText('Clear');
    fireEvent.click(clearButton);
    expect(
      screen.queryByText('Date and time are required')
    ).toBeInTheDocument();
    expect(dateTimeInput).toHaveAttribute('aria-invalid', 'true');
  });

  test('passes props to components', () => {
    const { container } = render(
      <DateTimePicker
        name="test-datetime"
        id="test-datetime-picker"
        locale="en-US"
        weekStartsOn={0}
        placement="bottom"
        required
      />
    );

    const dateTimeInput = container.querySelector(
      'input[name="test-datetime"]'
    );

    expect(dateTimeInput).toBeInTheDocument();
    expect(dateTimeInput).toHaveAttribute('name', 'test-datetime');
    expect(dateTimeInput).toHaveAttribute('id', 'test-datetime-picker');
    expect(dateTimeInput).toHaveAttribute('required', '');
  });

  test('renders TimePicker component', () => {
    const { container } = render(<DateTimePicker />);

    const timePickerInput = container.querySelector(
      'input[aria-label="Time picker"]'
    );
    expect(timePickerInput).toBeInTheDocument();
  });

  test('handles onBlur to format date and time', () => {
    const { container } = render(<DateTimePicker />);

    const dateTimeInput = container.querySelector(
      'input[aria-label="date and time picker"]'
    );

    fireEvent.change(dateTimeInput, { target: { value: '2024-01-15  14:30' } });
    expect(dateTimeInput).toHaveValue('2024-01-15  14:30');
    fireEvent.blur(dateTimeInput);

    expect(dateTimeInput).toHaveValue('2024-01-15 14:30');
  });

  describe('isFutureOnly validation', () => {
    test('shows error when past date is entered with isFutureOnly', () => {
      const pastDate = new Date();
      pastDate.setFullYear(pastDate.getFullYear() - 1);
      const pastDateString = `${pastDate.getFullYear()}-${String(
        pastDate.getMonth() + 1
      ).padStart(2, '0')}-${String(pastDate.getDate()).padStart(2, '0')} 14:30`;

      const { container } = render(<DateTimePicker isFutureOnly />);

      const dateTimeInput = container.querySelector(
        'input[aria-label="date and time picker"]'
      );
      expect(
        screen.queryByText('Date must be in the future')
      ).not.toBeInTheDocument();
      fireEvent.change(dateTimeInput, { target: { value: pastDateString } });
      fireEvent.blur(dateTimeInput);

      expect(
        screen.queryByText('Date must be in the future')
      ).toBeInTheDocument();
      expect(dateTimeInput).toHaveAttribute('aria-invalid', 'true');
    });

    test('does not show error when future date is entered with isFutureOnly', () => {
      const futureDate = new Date();
      futureDate.setFullYear(futureDate.getFullYear() + 1);
      const futureDateString = `${futureDate.getFullYear()}-${String(
        futureDate.getMonth() + 1
      ).padStart(2, '0')}-${String(futureDate.getDate()).padStart(
        2,
        '0'
      )} 14:30`;

      const { container } = render(<DateTimePicker isFutureOnly />);

      const dateTimeInput = container.querySelector(
        'input[aria-label="date and time picker"]'
      );

      fireEvent.change(dateTimeInput, { target: { value: futureDateString } });
      fireEvent.blur(dateTimeInput);

      expect(
        screen.queryByText('Date must be in the future')
      ).not.toBeInTheDocument();
      expect(dateTimeInput).not.toHaveAttribute('aria-invalid', 'true');
    });

    test('allows past dates when isFutureOnly is false', () => {
      const pastDate = new Date();
      pastDate.setFullYear(pastDate.getFullYear() - 1);
      const pastDateString = `${pastDate.getFullYear()}-${String(
        pastDate.getMonth() + 1
      ).padStart(2, '0')}-${String(pastDate.getDate()).padStart(2, '0')} 14:30`;

      const { container } = render(<DateTimePicker isFutureOnly={false} />);

      const dateTimeInput = container.querySelector(
        'input[aria-label="date and time picker"]'
      );

      fireEvent.change(dateTimeInput, { target: { value: pastDateString } });
      fireEvent.blur(dateTimeInput);

      expect(
        screen.queryByText('Date must be in the future')
      ).not.toBeInTheDocument();
    });

    test('shows error when current date with past time is entered with isFutureOnly', () => {
      const now = new Date();
      const pastTime = new Date(now);
      pastTime.setHours(now.getHours() - 1);
      const pastTimeString = `${now.getFullYear()}-${String(
        now.getMonth() + 1
      ).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')} ${String(
        pastTime.getHours()
      ).padStart(2, '0')}:${String(pastTime.getMinutes()).padStart(2, '0')}`;

      const { container } = render(<DateTimePicker isFutureOnly />);

      const dateTimeInput = container.querySelector(
        'input[aria-label="date and time picker"]'
      );

      fireEvent.change(dateTimeInput, { target: { value: pastTimeString } });
      fireEvent.blur(dateTimeInput);

      expect(
        screen.queryByText('Date must be in the future')
      ).toBeInTheDocument();
      expect(dateTimeInput).toHaveAttribute('aria-invalid', 'true');
    });

    test('does not show error when current date with future time is entered with isFutureOnly', () => {
      const now = new Date();
      const futureTime = new Date(now);
      futureTime.setHours(now.getHours() + 1);
      const futureTimeString = `${now.getFullYear()}-${String(
        now.getMonth() + 1
      ).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')} ${String(
        futureTime.getHours()
      ).padStart(2, '0')}:${String(futureTime.getMinutes()).padStart(2, '0')}`;

      const { container } = render(<DateTimePicker isFutureOnly />);

      const dateTimeInput = container.querySelector(
        'input[aria-label="date and time picker"]'
      );

      fireEvent.change(dateTimeInput, { target: { value: futureTimeString } });
      fireEvent.blur(dateTimeInput);

      expect(
        screen.queryByText('Date must be in the future')
      ).not.toBeInTheDocument();
      expect(dateTimeInput).not.toHaveAttribute('aria-invalid', 'true');
    });
  });
});
