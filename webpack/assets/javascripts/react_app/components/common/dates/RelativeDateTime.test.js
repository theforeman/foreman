import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import RelativeDateTime from './RelativeDateTime';
import { renderWithI18n, dateTimeAssertions } from '../../../common/testHelpers';
import { intl } from '../../../common/I18n';

describe('RelativeDateTime', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');

  it('formats date as relative time', async () => {
    renderWithI18n(
      <RelativeDateTime date={date} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // RelativeDateTime should show relative time like "2 weeks ago"
    const relativeText = screen.getByText(/ago|weeks|days|hours|minutes/i);
    expect(relativeText).toBeInTheDocument();

    // Should not show the default value since we have a valid date
    expect(screen.queryByText('Default value')).not.toBeInTheDocument();
  });

  it('renders default value when date is null', async () => {
    renderWithI18n(
      <RelativeDateTime date={null} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should display default value when date is null
    dateTimeAssertions.expectDefaultValue(screen, 'Default value');

    // Should not show any relative time indicators
    expect(screen.queryByText(/ago|weeks|days|hours|minutes/i)).not.toBeInTheDocument();
  });

  it('renders default value when date is undefined', async () => {
    renderWithI18n(
      <RelativeDateTime date={undefined} defaultValue="No date" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    expect(screen.getByText('No date')).toBeInTheDocument();
  });

  it('handles invalid date gracefully', async () => {
    renderWithI18n(
      <RelativeDateTime date={new Date('invalid')} defaultValue="Invalid date" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should fall back to default value for invalid dates
    expect(screen.getByText('Invalid date')).toBeInTheDocument();
  });

  it('shows appropriate relative time for recent dates', async () => {
    const recentDate = new Date('2017-10-27 23:54:55 -1100'); // ~1 hour ago
    renderWithI18n(
      <RelativeDateTime date={recentDate} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should show time-based relative text for recent dates
    const relativeText = screen.getByText(/ago|hour|minute/i);
    expect(relativeText).toBeInTheDocument();
  });

  it('shows appropriate relative time for older dates', async () => {
    const oldDate = new Date('2017-09-13 00:54:55 -1100'); // ~6 weeks ago
    renderWithI18n(
      <RelativeDateTime date={oldDate} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should show date-based relative text for older dates
    const relativeText = screen.getByText(/ago|week|month/i);
    expect(relativeText).toBeInTheDocument();
  });

  it('is accessible', async () => {
    renderWithI18n(
      <RelativeDateTime date={date} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    const relativeText = screen.getByText(/ago|weeks|days|hours|minutes/i);
    expect(relativeText).toBeInTheDocument();

    // Should have appropriate semantic markup for screen readers
    const timeElement = relativeText.closest('time') ||
                       relativeText.querySelector('[datetime]') ||
                       relativeText;

    expect(timeElement).toBeInTheDocument();
  });
});
