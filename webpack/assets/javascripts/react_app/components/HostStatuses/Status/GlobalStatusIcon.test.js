import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';
import GlobalStatusIcon from './GlobalStatusIcon';
import {
  GLOBAL_STATUS_OK,
  GLOBAL_STATUS_WARN,
  GLOBAL_STATUS_ERROR,
} from '../HostStatusesConstants';

// PF6 Icon sets its own content color; the status modifier is what colors it
const contentOf = container =>
  container.querySelector('.pf-v6-c-icon .pf-v6-c-icon__content');

describe('GlobalStatusIcon', () => {
  it.each([
    [GLOBAL_STATUS_OK, 'pf-m-success'],
    [GLOBAL_STATUS_WARN, 'pf-m-warning'],
    [GLOBAL_STATUS_ERROR, 'pf-m-danger'],
    [undefined, 'pf-m-info'],
  ])('colors status %s with %s', (status, modifier) => {
    const { container } = render(<GlobalStatusIcon status={status} />);
    expect(contentOf(container)).toHaveClass(modifier);
  });
});
