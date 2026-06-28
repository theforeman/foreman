import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import IsoDate from './IsoDate';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';

describe('IsoDate', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');

  const renderIsoDate = (props = {}) => {
    const IntlIsoDate = i18nProviderWrapperFactory(now, 'UTC')(IsoDate);

    return render(<IntlIsoDate defaultValue="Default value" {...props} />);
  };

  it('formats the date as month/day/year', async () => {
    renderIsoDate({ date });

    expect(await screen.findByText('10/13/2017')).toBeInTheDocument();
  });

  it('sets the title to the relative time', async () => {
    renderIsoDate({ date });

    await screen.findByText('10/13/2017');
    expect(screen.getByTitle('15 days ago')).toBeInTheDocument();
  });

  it('renders the default value when no date is provided', async () => {
    renderIsoDate({ date: null });

    expect(await screen.findByText('Default value')).toBeInTheDocument();
  });
});
