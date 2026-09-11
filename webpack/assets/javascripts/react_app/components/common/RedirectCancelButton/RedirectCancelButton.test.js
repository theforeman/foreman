import React from 'react';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import '@testing-library/jest-dom';

import RedirectCancelButton from './RedirectCancelButton';

jest.mock('../../../common/withReactRoutes', () => Component => props => (
  <div className="component-with-mocked-routes">
    <Component {...props} />
  </div>
));

describe('RedirectCancelButton', () => {
  it('renders correctly', () => {
    const { container } = render(
      <MemoryRouter>
        <RedirectCancelButton cancelPath="/hosts" />
      </MemoryRouter>
    );

    // renders a Cancel button linking to the cancel path
    expect(screen.getByText('Cancel')).toBeInTheDocument();
    expect(screen.getByRole('link')).toHaveAttribute('href', '/hosts');
  });
});
