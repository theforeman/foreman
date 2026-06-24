import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import RelativeDateTime from './RelativeDateTime';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';

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
});
