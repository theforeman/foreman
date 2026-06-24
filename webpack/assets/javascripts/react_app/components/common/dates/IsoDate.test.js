import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import IsoDate from './IsoDate';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';

describe('IsoDate', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');
  const IntlIsoDate = i18nProviderWrapperFactory(now, 'UTC')(IsoDate);

  test('formats date as MM/DD/YYYY', async () => {
    render(<IntlIsoDate date={date} defaultValue="Default value" />);

    expect(await screen.findByText('10/13/2017')).toBeInTheDocument();
  });

  test('shows relative time in the title attribute', async () => {
    render(<IntlIsoDate date={date} defaultValue="Default value" />);

    expect(await screen.findByTitle('15 days ago')).toBeInTheDocument();
  });

  test('formats non-ISO date strings from the API', async () => {
    render(
      <IntlIsoDate
        date="2017-10-13 00:54:55 -1100"
        defaultValue="Default value"
      />
    );

    expect(await screen.findByText('10/13/2017')).toBeInTheDocument();
    expect(await screen.findByTitle('15 days ago')).toBeInTheDocument();
  });

  test('renders default value when date is null', async () => {
    render(<IntlIsoDate date={null} defaultValue="Default value" />);

    expect(await screen.findByText('Default value')).toBeInTheDocument();
  });

  test('renders empty string when date is null and no default value is provided', async () => {
    const { container } = render(<IntlIsoDate date={null} />);

    await screen.findByText((content, element) => {
      return element.tagName === 'SPAN' && content === '';
    });

    expect(container.querySelector('span')).toBeEmptyDOMElement();
  });
});
