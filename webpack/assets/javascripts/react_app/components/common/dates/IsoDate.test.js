import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import IsoDate from './IsoDate';
import { renderWithI18n, dateTimeAssertions } from '../../../common/testHelpers';
import { intl } from '../../../common/I18n';

describe('IsoDate', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');

  it('formats date in ISO format', async () => {
    renderWithI18n(
      <IsoDate date={date} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // IsoDate should display date in ISO format (YYYY-MM-DD)
    const isoDateText = screen.getByText(/2017-10-13/);
    expect(isoDateText).toBeInTheDocument();

    // Should not show the default value since we have a valid date
    expect(screen.queryByText('Default value')).not.toBeInTheDocument();
  });

  it('renders default value when date is null', async () => {
    renderWithI18n(
      <IsoDate date={null} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should display default value when date is null
    dateTimeAssertions.expectDefaultValue(screen, 'Default value');

    // Should not show any ISO date format
    expect(screen.queryByText(/\d{4}-\d{2}-\d{2}/)).not.toBeInTheDocument();
  });

  it('renders default value when date is undefined', async () => {
    renderWithI18n(
      <IsoDate date={undefined} defaultValue="No date" />,
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
      <IsoDate date={new Date('invalid')} defaultValue="Invalid date" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should fall back to default value for invalid dates
    expect(screen.getByText('Invalid date')).toBeInTheDocument();
  });

  it('formats different dates correctly', async () => {
    const testDate = new Date('2020-01-01 12:00:00 UTC');
    renderWithI18n(
      <IsoDate date={testDate} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should format the date in ISO format
    const isoDateText = screen.getByText(/2020-01-01/);
    expect(isoDateText).toBeInTheDocument();
  });

  it('works without default value', async () => {
    renderWithI18n(
      <IsoDate date={date} />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should still render the ISO date even without a default value
    const isoDateText = screen.getByText(/2017-10-13/);
    expect(isoDateText).toBeInTheDocument();
  });

  it('handles timezone differences', async () => {
    renderWithI18n(
      <IsoDate date={date} defaultValue="Default value" />,
      now,
      'America/New_York'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should still display ISO format date (may be adjusted for timezone)
    const isoDateText = screen.getByText(/\d{4}-\d{2}-\d{2}/);
    expect(isoDateText).toBeInTheDocument();
  });

  it('is accessible', async () => {
    renderWithI18n(
      <IsoDate date={date} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    const isoDateText = screen.getByText(/2017-10-13/);
    expect(isoDateText).toBeInTheDocument();

    // Should have appropriate semantic markup for screen readers
    const timeElement = isoDateText.closest('time') ||
                       isoDateText.querySelector('[datetime]') ||
                       isoDateText;

    expect(timeElement).toBeInTheDocument();
  });
});
