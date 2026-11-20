import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import StatusIcon from './StatusIcon';
import {
  ERROR_STATUS_STATE,
  NA_STATUS_STATE,
  OK_STATUS_STATE,
  WARNING_STATUS_STATE,
} from './Constants';

const contentOf = container =>
  container.querySelector('.pf-v6-c-icon .pf-v6-c-icon__content');

describe('StatusIcon', () => {
  it.each([
    [OK_STATUS_STATE, 'pf-m-success'],
    [WARNING_STATUS_STATE, 'pf-m-warning'],
    [ERROR_STATUS_STATE, 'pf-m-danger'],
  ])('colors the icon for status %s with %s', (statusNumber, modifier) => {
    const { container } = render(
      <StatusIcon statusNumber={statusNumber} label="Build" />
    );
    expect(contentOf(container)).toHaveClass(modifier);
    expect(screen.getByText('Build')).toBeInTheDocument();
  });

  it('greys out the icon for a status that does not apply', () => {
    const { container } = render(
      <StatusIcon statusNumber={NA_STATUS_STATE} label="Build" />
    );
    expect(
      container
        .querySelector('.pf-v6-c-icon')
        .style.getPropertyValue('--pf-v6-c-icon__content--Color')
    ).toBe('var(--pf-t--global--icon--color--disabled)');
  });
});
