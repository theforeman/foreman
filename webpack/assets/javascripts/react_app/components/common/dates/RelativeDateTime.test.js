import React from 'react';
import { act, render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import RelativeDateTime from './RelativeDateTime';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';
import { intl } from '../../../common/I18n';

describe('RelativeDateTime', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');
  const IntlRelativeDateTime = i18nProviderWrapperFactory(
    now,
    'UTC'
  )(RelativeDateTime);

  const renderRelativeDateTime = props =>
    render(<IntlRelativeDateTime {...props} />);

  it('renders formatted relative time for a given date', async () => {
    renderRelativeDateTime({ date, defaultValue: 'Default value' });

    expect(await screen.findByText('15 days ago')).toBeInTheDocument();
  });

  it('sets title attribute with absolute formatted date', async () => {
    renderRelativeDateTime({ date, defaultValue: 'Default value' });

    await screen.findByText('15 days ago');
    expect(screen.getByTitle('Oct 13, 2017, 11:54 AM')).toBeInTheDocument();
  });

  it('renders default value when date is null', async () => {
    renderRelativeDateTime({ date: null, defaultValue: 'Default value' });

    expect(await screen.findByText('Default value')).toBeInTheDocument();
  });

  it('renders custom children with formatted relative time', async () => {
    renderRelativeDateTime({
      date,
      defaultValue: 'Default value',
      children: relativeDate => `Created ${relativeDate}`,
    });

    expect(await screen.findByText('Created 15 days ago')).toBeInTheDocument();
  });

  it('updates the relative time as time passes', async () => {
    jest.useFakeTimers('modern');
    try {
      const start = new Date();
      const RecentRelativeDateTime = i18nProviderWrapperFactory(
        start,
        'UTC'
      )(RelativeDateTime);

      render(
        <RecentRelativeDateTime date={new Date(start.getTime() - 1000)} />
      );

      await act(async () => {
        await intl.ready;
      });

      expect(screen.getByText('1 second ago')).toBeInTheDocument();

      act(() => {
        jest.advanceTimersByTime(10000);
      });

      expect(screen.getByText('11 seconds ago')).toBeInTheDocument();
    } finally {
      jest.useRealTimers();
    }
  });
});
