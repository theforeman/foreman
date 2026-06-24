import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ShortDateTime from './ShortDateTime';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';

describe('ShortDateTime', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');

  const renderShortDateTime = (props = {}) => {
    const IntlShortDateTime = i18nProviderWrapperFactory(now, 'UTC')(
      ShortDateTime
    );

    return render(
      <IntlShortDateTime defaultValue="Default value" {...props} />
    );
  };

  describe('when a date is provided', () => {
    it('renders the date in short month, day, and time format', async () => {
      renderShortDateTime({ date });

      expect(await screen.findByText('Oct 13, 11:54 AM')).toBeInTheDocument();
    });

    it('formats non-ISO date strings', async () => {
      renderShortDateTime({ date: '2017-10-13 00:54:55 -1100' });

      expect(await screen.findByText('Oct 13, 11:54 AM')).toBeInTheDocument();
    });

    it('includes seconds in the formatted time when seconds is enabled', async () => {
      renderShortDateTime({ date, seconds: true });

      expect(
        await screen.findByText('Oct 13, 11:54:55 AM')
      ).toBeInTheDocument();
    });

    it('sets the title to relative time when showRelativeTimeTooltip is enabled', async () => {
      renderShortDateTime({ date, showRelativeTimeTooltip: true });

      await screen.findByText('Oct 13, 11:54 AM');
      expect(screen.getByTitle('15 days ago')).toBeInTheDocument();
    });

    it('does not set a title attribute when showRelativeTimeTooltip is disabled', async () => {
      renderShortDateTime({ date });

      expect(
        await screen.findByText('Oct 13, 11:54 AM')
      ).not.toHaveAttribute('title');
    });
  });

  describe('when no date is provided', () => {
    it('renders the default value when date is null', async () => {
      renderShortDateTime({ date: null });

      expect(await screen.findByText('Default value')).toBeInTheDocument();
    });

    it('renders the default value when date is undefined', async () => {
      renderShortDateTime({ date: undefined });

      expect(await screen.findByText('Default value')).toBeInTheDocument();
    });

    it('renders an empty string when date is null and no default value is given', async () => {
      renderShortDateTime({
        date: null,
        defaultValue: '',
      });

      await screen.findByText('', { selector: 'span' });
    });
  });
});
