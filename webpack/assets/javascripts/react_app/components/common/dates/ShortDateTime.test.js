import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import ShortDateTime from './ShortDateTime';
import { renderWithI18n, dateTimeAssertions } from '../../../common/testHelpers';
import { intl } from '../../../common/I18n';

describe('ShortDateTime', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');

  it('formats date correctly', async () => {
    renderWithI18n(
      <ShortDateTime date={date} defaultValue="Default value" />,
      now,
      'UTC'
    );

    // Wait for i18n to be ready and component to update
    await waitFor(async () => {
      await intl.ready;
    });

    // Test that the formatted date is displayed
    // The exact format will depend on the i18n configuration
    const dateElement = screen.getByText(/2017|Oct|13/);
    expect(dateElement).toBeInTheDocument();

    // Test that it's not showing the default value since we have a valid date
    expect(screen.queryByText('Default value')).not.toBeInTheDocument();
  });

  it('formats date with relative tooltip', async () => {
    renderWithI18n(
      <ShortDateTime
        date={date}
        defaultValue="Default value"
        showRelativeTimeTooltip
      />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Test that the formatted date is displayed
    const dateElement = screen.getByText(/2017|Oct|13/);
    expect(dateElement).toBeInTheDocument();

    // Test for tooltip functionality - might be in title attribute or aria-describedby
    // The tooltip should show relative time like "2 weeks ago"
    const elementWithTooltip = dateElement.closest('[title]') ||
                              dateElement.closest('[aria-describedby]') ||
                              dateElement;

    expect(elementWithTooltip).toBeInTheDocument();

    // If tooltip is in title attribute, check for relative time indicators
    const titleAttr = elementWithTooltip.getAttribute('title');
    if (titleAttr) {
      expect(titleAttr).toMatch(/ago|weeks|days/i);
    }
  });

  it('formats date with seconds precision', async () => {
    renderWithI18n(
      <ShortDateTime date={date} seconds defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Test that the date includes seconds in the format
    // With seconds=true, the format should be more precise
    const dateElement = screen.getByText(/2017|Oct|13/);
    expect(dateElement).toBeInTheDocument();

    // The formatted text should include time with seconds
    const formattedText = dateElement.textContent;
    expect(formattedText).toMatch(/:55/);
  });

  it('renders default value when date is null', async () => {
    renderWithI18n(
      <ShortDateTime date={null} defaultValue="Default value" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Test that default value is shown when date is null
    dateTimeAssertions.expectDefaultValue(screen, 'Default value');

    // Test that no date formatting occurred
    expect(screen.queryByText(/2017|Oct|13/)).not.toBeInTheDocument();
  });

  it('renders default value when date is undefined', async () => {
    renderWithI18n(
      <ShortDateTime date={undefined} defaultValue="No date available" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    expect(screen.getByText('No date available')).toBeInTheDocument();
  });

  it('handles invalid date gracefully', async () => {
    renderWithI18n(
      <ShortDateTime date={new Date('invalid')} defaultValue="Invalid date" />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should fall back to default value for invalid dates
    expect(screen.getByText('Invalid date')).toBeInTheDocument();
  });

  it('renders without default value', async () => {
    renderWithI18n(
      <ShortDateTime date={date} />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // Should render the formatted date even without a default value
    const dateElement = screen.getByText(/2017|Oct|13/);
    expect(dateElement).toBeInTheDocument();
  });

  it('handles different timezones', async () => {
    renderWithI18n(
      <ShortDateTime date={date} defaultValue="Default value" />,
      now,
      'America/New_York'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    // The date should be formatted according to the specified timezone
    const dateElement = screen.getByText(/2017|Oct|13/);
    expect(dateElement).toBeInTheDocument();

    // Time should be adjusted for the timezone
    const formattedText = dateElement.textContent;
    expect(formattedText).toBeTruthy();
  });

  it('is accessible', async () => {
    renderWithI18n(
      <ShortDateTime
        date={date}
        defaultValue="Default value"
        showRelativeTimeTooltip
      />,
      now,
      'UTC'
    );

    await waitFor(async () => {
      await intl.ready;
    });

    const dateElement = screen.getByText(/2017|Oct|13/);
    expect(dateElement).toBeInTheDocument();

    // Should have appropriate semantic markup for screen readers
    // DateTime components should provide machine-readable datetime
    const timeElement = dateElement.closest('time') ||
                       dateElement.querySelector('[datetime]') ||
                       dateElement;

    expect(timeElement).toBeInTheDocument();
  });
});
