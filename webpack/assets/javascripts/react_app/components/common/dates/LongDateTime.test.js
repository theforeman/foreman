import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';

import LongDateTime from './LongDateTime';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';

describe('LongDateTime', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');
  const IntlLongDateTime = i18nProviderWrapperFactory(now, 'UTC')(LongDateTime);

  const renderLongDateTime = props =>
    render(<IntlLongDateTime {...props} />);

  const longDateTimePattern = /October 13, 2017[, at]+ 11:54(:\d{2})? AM/;

  it('renders a formatted long date and time without seconds', async () => {
    renderLongDateTime({ date, defaultValue: 'Default value' });

    await waitFor(() => {
      expect(screen.getByText(longDateTimePattern)).toBeInTheDocument();
    });
    expect(screen.getByText(longDateTimePattern).textContent).not.toMatch(
      /11:54:\d{2} AM/
    );
  });

  it('renders a formatted long date and time with seconds when enabled', async () => {
    renderLongDateTime({ date, seconds: true, defaultValue: 'Default value' });

    await waitFor(() => {
      expect(
        screen.getByText(/October 13, 2017[, at]+ 11:54:55 AM/)
      ).toBeInTheDocument();
    });
  });

  it('shows a relative time tooltip when showRelativeTimeTooltip is enabled', async () => {
    renderLongDateTime({
      date,
      defaultValue: 'Default value',
      showRelativeTimeTooltip: true,
    });

    await waitFor(() => {
      expect(screen.getByTitle('15 days ago')).toBeInTheDocument();
    });
    expect(screen.getByTitle('15 days ago')).toHaveTextContent(
      longDateTimePattern
    );
  });

  it('does not show a relative time tooltip when showRelativeTimeTooltip is disabled', async () => {
    renderLongDateTime({ date, defaultValue: 'Default value' });

    await waitFor(() => {
      expect(screen.getByText(longDateTimePattern)).toBeInTheDocument();
    });
    expect(screen.queryByTitle('15 days ago')).not.toBeInTheDocument();
  });

  it('renders the default value when date is null', async () => {
    renderLongDateTime({ date: null, defaultValue: 'Default value' });

    await waitFor(() => {
      expect(screen.getByText('Default value')).toBeInTheDocument();
    });
  });

  it('renders an empty string when date is null and no default value is provided', async () => {
    const { container } = renderLongDateTime({ date: null });

    await waitFor(() => {
      expect(container.querySelector('span')).toBeInTheDocument();
    });
    expect(container.querySelector('span')).toHaveTextContent('');
  });

  it('formats a non-ISO date string', async () => {
    renderLongDateTime({
      date: '2017-10-13 00:54:55 -1100',
      defaultValue: 'Default value',
    });

    await waitFor(() => {
      expect(screen.getByText(longDateTimePattern)).toBeInTheDocument();
    });
  });
});
