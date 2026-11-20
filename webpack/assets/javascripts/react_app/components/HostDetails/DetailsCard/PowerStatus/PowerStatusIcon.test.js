import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';
import PowerStatusIcon from './PowerStatusIcon';
import { STATUS } from '../../../../constants';

const renderIcon = state =>
  render(<PowerStatusIcon state={state} responseStatus={STATUS.RESOLVED} />)
    .container;

describe('PowerStatusIcon', () => {
  it('shows a powered-on host as success', () => {
    expect(
      renderIcon('on').querySelector('.pf-v6-c-icon__content')
    ).toHaveClass('pf-m-success');
  });

  it('shows a powered-off host as danger', () => {
    expect(
      renderIcon('off').querySelector('.pf-v6-c-icon__content')
    ).toHaveClass('pf-m-danger');
  });

  it('greys out an unknown power state', () => {
    expect(
      renderIcon('na')
        .querySelector('.pf-v6-c-icon')
        .style.getPropertyValue('--pf-v6-c-icon__content--Color')
    ).toBe('var(--pf-t--global--icon--color--disabled)');
  });
});
