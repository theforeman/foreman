import React from 'react';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import '@testing-library/jest-dom';

import store from '../../../../redux';
import UpgradePage from '../../UpgradePage';

describe('UpgradePage', () => {
  it('renders UpgradePage component', () => {
    const page = <Provider store={store}>
      <UpgradePage />
    </Provider>;
    render(page);

    // Main page
    expect(screen.getByText(/Foreman upgrade/i)).toBeInTheDocument();

    // Button from DocumentationCard
    const docsLinkBtn = screen.getByRole('link', {
      name: /View upgrade documentation/i,
    });
    expect(docsLinkBtn).toBeInTheDocument();
    expect(docsLinkBtn).toHaveAttribute('href', '/links/upgrade/documentation');

    // Button from DocumentationFooter
    const helpLinkBtn = screen.getByRole('link', {
      name: /Visit the community forum/i,
    });
    expect(helpLinkBtn).toBeInTheDocument();
    expect(helpLinkBtn).toHaveAttribute('href', '/links/support');
  });
});
